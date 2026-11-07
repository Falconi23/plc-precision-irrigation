// Declaration block of PROGRAM MAIN (TwinCAT 3, PLC/POUs/MAIN.TcPOU), the only POU, run by PlcTask every 10 ms.
// Omitted: one duplicated OPC.UA.DA pragma line that had no effect.

// Identifiers are Italian: Sensore = sensor input, Comando = actuator output,
// Sx/Dx = left/right, Aratura = plough, Semina = seeder, Pioggia = rain,
// IrrigazioneAuto (IA) = water tanker, IrrigazioneTubo (IT) = hose sprinkler.
// {attribute 'OPC.UA.DA' := '1'} exposes the next variable on the TwinCAT OPC UA server.
PROGRAM MAIN
VAR
    // Operator inputs, not exported.
    SensoreSTART : BOOL := FALSE;
    SensoreRESET : BOOL := FALSE;   // acknowledge, returns the SFC to Init
    SensoreEND   : BOOL := FALSE;   // declared but unused by the SFC

    // Limit switches.
    {attribute 'OPC.UA.DA' := '1'}
    SensoreRD   : BOOL := FALSE;    // rain delivered
    {attribute 'OPC.UA.DA' := '1'}
    SensoreASx  : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    SensoreADx  : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    SensoreSSx  : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    SensoreSDx  : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    SensoreIADx : BOOL := FALSE;    // set by the HMI to pick the tanker branch
    {attribute 'OPC.UA.DA' := '1'}
    SensoreIASx : BOOL := FALSE;    // tanker arm limit switch (Sx): ends the first stroke, starts the return
    {attribute 'OPC.UA.DA' := '1'}
    SensoreITDx : BOOL := FALSE;    // set by the HMI to pick the hose branch
    {attribute 'OPC.UA.DA' := '1'}
    SensoreITSx : BOOL := FALSE;    // hose arm limit switch (Sx): ends the first stroke, starts the return

    {attribute 'OPC.UA.DA' := '1'}
    ComandoPioggiaMoveDown   : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    ComandoIrrigazioneAutoDx : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    ComandoIrrigazioneAutoSx : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    ComandoIrrigazioneTuboDx : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    ComandoIrrigazioneTuboSx : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    ComandoAraturaSx : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    ComandoAraturaDx : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    ComandoSeminaSx  : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    ComandoSeminaDx  : BOOL := FALSE;
    {attribute 'OPC.UA.DA' := '1'}
    ComandoALLARME   : BOOL := FALSE;          // set by the watchdog abort branch

    fbTimer        : TON;              // watchdog
    TimerWatchDog  : TIME := T#5s;     // PT; the HMI can overwrite it via ADS
    TimerAct       : TIME := T#0S;     // fbTimer.ET mirrored for the HMI
END_VAR
