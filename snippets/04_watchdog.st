// TON watchdog on the rain step: ACT1, ACT2 (watchdog line only), ACT10, TRANS1, TRANS12, TRANS13
// from PLC/POUs/MAIN.TcPOU. Declarations in 01_variables.st.

// Without the abort branch a failed actuator or sensor in Step0 would leave the
// SFC waiting there forever with no fault shown. From the alarm step only RESET
// returns to Init.
//
// A TON only updates when called, and N actions stop running once their step
// is left, so the timer would keep its last Q/ET. The next step (ACT2, or ACT10
// on abort) calls it once with IN := FALSE to clear it.

// ACT1 (Step0, N: every cycle while Step0 is active)
ComandoPioggiaMoveDown := TRUE;
fbTIMER(IN:=TRUE, PT:=TimerWatchDog);           // ST is case-insensitive: same instance as fbTimer
TimerAct := fbTimer.ET;                         // read by the HMI over ADS

// TRANS1 (Branch2 left arm, Step0 -> Step2): rain before the timeout.
SensoreRD AND NOT fbTimer.Q;

// TRANS12 (Branch2 right arm, Step0 -> Step11): timeout, 5 s by default, with no rain.
fbTimer.Q AND NOT SensoreRD;

// ACT2 (Step2), watchdog line only
fbTimer(IN := FALSE, PT := TimerWatchDog);

// ACT10 (Step11, abort)
ComandoALLARME := TRUE;
fbTimer(IN := FALSE, PT := TimerWatchDog);

// TRANS13 (Step11 -> jump to Init). The alarm itself is cleared by the HMI
// restart button writing ComandoALLARME := FALSE over ADS.
SensoreRESET;
