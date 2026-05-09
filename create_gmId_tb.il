; =========================================================================
; create_gmId_tb.il
; SKILL script to programmatically create a unified diode-connected 
; testbench for simultaneous NMOS and PMOS gm/Id characterization.
; Fully Generalized for any PDK.
; =========================================================================

printf("\n================================================================\n")
printf("       UNIFIED NMOS/PMOS TESTBENCH GENERATOR INITIATED          \n")
printf("================================================================\n")

; =========================================================================
; !!! USER CONFIGURATION VARIABLES - UPDATE THESE AS NEEDED !!!
; =========================================================================

; 1. Target PDK & Device Models
pdkLib           = "tsmcN65"  ; Change to "tsmc18", "gpdk180", etc.
nmosType         = "nch"      ; Change to "nch_25", "nmos1v", etc.
pmosType         = "pch"      ; Change to "pch_25", "pmos1v", etc.

; 2. Testbench Naming
libraryName      = "gm_Id_characterization"
cellName         = "nmos_pmos_tb"
viewName         = "schematic"

; =========================================================================
; HELPER FUNCTIONS
; =========================================================================

; Helper 1: Place Instances
procedure( createInstSafe(cv lib cell view x y refname)
  let((master inst)
    master = dbOpenCellViewByType(lib cell view)
    if( master then
        inst = dbCreateInst(cv master refname list(x y) "R0")
        dbClose(master)
        inst
    else
        printf("     [ERROR] Could not open master %s/%s/%s\n" lib cell view)
        nil
    )
  )
)

; Helper 2: Update CDF Parameter and Trigger Callbacks
procedure( updateCDFParam(inst paramName paramVal)
  let( (cdf param)
    cdf = cdfGetInstCDF(inst)
    if( cdf then
        param = cdfFindParamByName(cdf paramName)
        if( param then
            param~>value = paramVal
            cdfgData = cdf
            if( param~>callback && param~>callback != "" then
                errset(evalstring(param~>callback) t)
            )
        )
    )
  )
)

; Helper 3: Draw an orthogonal wire stub and attach a Net Label
procedure( connectPinByLabel(cv inst pinName netName dx dy justification)
  let( (masterTerm pinBBox pinX pinY absPt endPt wireLines)
    
    masterTerm = dbFindTermByName(inst~>master pinName)
    if( null(masterTerm) then masterTerm = dbFindTermByName(inst~>master lowerCase(pinName)) )
    if( null(masterTerm) && pinName == "gnd!" then masterTerm = dbFindTermByName(inst~>master "gnd") )
    
    if( masterTerm && masterTerm~>pins then
        pinBBox = car(masterTerm~>pins)~>fig~>bBox
        pinX = (xCoord(lowerLeft(pinBBox)) + xCoord(upperRight(pinBBox))) / 2.0
        pinY = (yCoord(lowerLeft(pinBBox)) + yCoord(upperRight(pinBBox))) / 2.0
        
        absPt = dbTransformPoint(list(pinX pinY) inst~>transform)
        endPt = list(xCoord(absPt) + dx yCoord(absPt) + dy)
        
        wireLines = schCreateWire(cv "draw" "direct" list(absPt endPt) 0.0625 0.0625 0.0)
        
        if( wireLines then
            schCreateWireLabel(cv car(wireLines) endPt netName justification "R0" "stick" 0.0625 nil)
        )
    )
  )
)

; =========================================================================
; EXECUTION SCRIPT
; =========================================================================

; 1. Library Check
printf("[1/4] Checking target library environment...\n")
if( not(ddGetObj(libraryName)) then
    printf("  -> Library '%s' not found. Creating new library...\n" libraryName)
    dbCreateLib(libraryName)
else
    printf("  -> Library '%s' verified.\n" libraryName)
)

; 2. Open cellview for writing
printf("[2/4] Initializing schematic database for '%s'...\n" cellName)
cv = dbOpenCellViewByType(libraryName cellName viewName "schematic" "w")

if( null(cv) then
     printf("  -> [FATAL ERROR] Could not open/create cellview %s:%s.%s\n" libraryName cellName viewName)
else
    ; Clear existing contents safely
    printf("  -> Purging existing layout elements...\n")
    foreach(inst cv~>instances dbDeleteObject(inst))
    foreach(shape cv~>shapes dbDeleteObject(shape))
    foreach(net cv~>nets dbDeleteObject(net))

    ; 3. Place ALL Components
    printf("[3/4] Generating topology and placing components...\n")
    
    printf("  -> Placing Global Power and Ground...\n")
    v1_inst    = createInstSafe(cv "analogLib" "vdc" "symbol" -3.0  1.0 "V1")
    if( v1_inst then updateCDFParam(v1_inst "vdc" "Vdd") )
    gnd_global = createInstSafe(cv "analogLib" "gnd" "symbol" -3.0 -0.5 "GND1")

    printf("  -> Placing NMOS DUT (%s) and Biasing elements...\n" nmosType)
    i_nmos = createInstSafe(cv "analogLib" "idc" "symbol"  0.0  2.0 "I0")
    if( i_nmos then updateCDFParam(i_nmos "idc" "Idc") i_nmos~>dc = "Idc" )
    
    m_nmos = createInstSafe(cv pdkLib nmosType "symbol"    0.0  0.0 "M0")
    if( m_nmos then updateCDFParam(m_nmos "w" "W") updateCDFParam(m_nmos "l" "L") )
    
    v_nmos_b = createInstSafe(cv "analogLib" "vdc" "symbol" 2.0  0.0 "V0")
    if( v_nmos_b then updateCDFParam(v_nmos_b "vdc" "Vbs_nmos") )

    printf("  -> Placing PMOS DUT (%s) and Biasing elements...\n" pmosType)
    m_pmos = createInstSafe(cv pdkLib pmosType "symbol"    5.0  2.0 "M1")
    if( m_pmos then updateCDFParam(m_pmos "w" "W") updateCDFParam(m_pmos "l" "L") )
    
    i_pmos = createInstSafe(cv "analogLib" "idc" "symbol"  5.0  0.0 "I1")
    if( i_pmos then updateCDFParam(i_pmos "idc" "Idc") i_pmos~>dc = "Idc" )
    
    v_pmos_b = createInstSafe(cv "analogLib" "vdc" "symbol" 7.0  2.0 "V2")
    if( v_pmos_b then updateCDFParam(v_pmos_b "vdc" "Vbs_pmos") )

    ; 4. Virtual Wiring
    printf("[4/4] Executing virtual routing and net labeling...\n")
    if( v1_inst && i_nmos && m_nmos && v_nmos_b && m_pmos && i_pmos && v_pmos_b then
        
        ; Global Supply Wiring
        connectPinByLabel(cv v1_inst "PLUS"  "vdd"   0.0  0.25 "lowerCenter")
        connectPinByLabel(cv v1_inst "MINUS" "gnd!"  0.0 -0.25 "upperCenter")
        if( gnd_global then connectPinByLabel(cv gnd_global "gnd!" "gnd!" 0.0 0.25 "lowerCenter") )

        ; NMOS Wiring
        connectPinByLabel(cv i_nmos "PLUS"  "vdd"               0.0  0.25 "lowerCenter")
        connectPinByLabel(cv i_nmos "MINUS" "drain_gate_nmos"   0.0 -0.25 "upperCenter")
        connectPinByLabel(cv m_nmos "D"     "drain_gate_nmos"   0.0  0.25 "lowerCenter")
        connectPinByLabel(cv m_nmos "G"     "drain_gate_nmos"  -0.35 0.0  "centerRight")
        connectPinByLabel(cv m_nmos "S"     "gnd!"              0.0 -0.25 "upperCenter")
        connectPinByLabel(cv m_nmos "B"     "vbs_nmos_net"      0.35 0.0  "centerLeft")
        connectPinByLabel(cv v_nmos_b "PLUS"  "vbs_nmos_net"    0.0  0.25 "lowerCenter")
        connectPinByLabel(cv v_nmos_b "MINUS" "gnd!"            0.0 -0.25 "upperCenter")

        ; PMOS Wiring
        connectPinByLabel(cv m_pmos "S"     "vdd"               0.0  0.25 "lowerCenter")
        connectPinByLabel(cv m_pmos "D"     "drain_gate_pmos"   0.0 -0.25 "upperCenter")
        connectPinByLabel(cv m_pmos "G"     "drain_gate_pmos"  -0.35 0.0  "centerRight")
        connectPinByLabel(cv m_pmos "B"     "vbs_pmos_net"      0.35 0.0  "centerLeft")
        connectPinByLabel(cv i_pmos "PLUS"  "drain_gate_pmos"   0.0  0.25 "lowerCenter")
        connectPinByLabel(cv i_pmos "MINUS" "gnd!"              0.0 -0.25 "upperCenter")
        connectPinByLabel(cv v_pmos_b "PLUS"  "vbs_pmos_net"    0.0  0.25 "lowerCenter")
        connectPinByLabel(cv v_pmos_b "MINUS" "vdd"             0.0 -0.25 "upperCenter")
    )

    ; Save and Close
    printf("  -> Running internal schematic rules check (schCheck)...\n")
    schCheck(cv)
    dbSave(cv)
    dbClose(cv)

    printf("\n================================================================\n")
    printf(" [SUCCESS] Testbench '%s' generated perfectly.\n" cellName)
    printf("================================================================\n\n")
)