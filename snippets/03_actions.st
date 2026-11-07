// Representative SFC actions and transitions from PLC/POUs/MAIN.TcPOU, one TwinCAT ST object each, shown in sequence.
// Omitted: ACT1/ACT10, TRANS1/12/13 (see 04_watchdog.st) and the tanker arm (ACT7/8, TRANS6/7), which mirrors the hose arm.
// Each step leaves on the limit switch at the end of its movement, never on a fixed delay.

// ACT2 (Step2, N). Rain arrived in time, so also clear the watchdog (see 04).
ComandoPioggiaMoveDown := FALSE;
ComandoAraturaSx := TRUE;
fbTimer(IN := FALSE, PT := TimerWatchDog);

// TRANS2 (Step2 -> Step3)
SensoreASx;

// ACT3 (Step3)
ComandoAraturaSx := FALSE;
ComandoAraturaDx := TRUE;

// TRANS3 (Step3 -> Step4)
SensoreADx;

// ACT4 (Step4)
ComandoAraturaDx := FALSE;
ComandoSeminaSx := TRUE;

// TRANS4 (Step4 -> Step5)
SensoreSSx;

// ACT5 (Step5)
ComandoSeminaSx := FALSE;
ComandoSeminaDx := TRUE;

// TRANS5 (Step5 -> Step6)
SensoreSDx;

// ACT6 (Step6). Step6 -> Step16 is unconditional, then the tanker/hose alternative branch.
ComandoSeminaDx := FALSE;


// TRANS9 (Step16 -> Step9, right arm of Branch3). The HMI picks the arm.
SensoreITDx;

// ACT9 (Step9)
ComandoIrrigazioneTuboDx := TRUE;

// TRANS90 (Step9 -> Step18)
SensoreITSx;

// ACT90 (Step18). Step18 -> Step12 is unconditional (branch convergence).
ComandoIrrigazioneTuboDx := FALSE;
ComandoIrrigazioneTuboSx := TRUE;


// TRANS0 (Init -> Step14)
SensoreSTART;

// TRANS11 (Step13 -> jump to Init)
SensoreRESET;
