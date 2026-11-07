# 06 - TwinCAT OPC UA server configuration

**Source:** the TwinCAT Connectivity project (`TwinCAT Connectivity TesinaRespa.tcconnproj`) and its `TwinCAT OPC UA Server Project1` folder. The configuration files are XML and are summarized here rather than copied.
**Omitted:** the machine name of the development VM, Visual Studio user files and the language resource file.

The connectivity project defines one TwinCAT OPC UA Server with its five standard modules. It sits beside the PLC and makes the PLC variables available to any OPC UA client (SCADA, IIoT gateway, UaExpert, ...). The control logic is not changed.

| Module | File | What is configured |
|---|---|---|
| Server | `TwinCAT OPC UA Server Project1.tcopcuasrv` | Endpoint `opc.tcp://localhost:4840` (UA port 4840). Anonymous login and username/password login are both enabled. |
| Data Access | `Data Access/Data Access.opcuada` | One node manager `PLC1`, connected over ADS to the PLC runtime (AMS Net ID `127.0.0.1.1.1`, port `851`, ADS timeout 2000 ms). The namespace is built automatically from the PLC symbol file `[BootDir]\Plc\Port_851.tmc`. |
| Historical Access | `Historical Access/Historical Access.opcuaha` | Module present. No history controller or history nodes defined yet. |
| Alarms & Conditions | `Alarms and Conditions/Alarms and Conditions.ac` | Module present. No alarm or condition definitions yet. |
| Security Access | `Security Access/Security Access.sec` | Group `Guests` with default access `0x0B` on the OPC UA namespace: attribute read + value read + browse, so the access is read-only. No users defined. |

## Which PLC variables are exposed

Data Access uses the PLC symbol file. Only the variables marked with the pragma `{attribute 'OPC.UA.DA' := '1'}` in `MAIN` (see `01_variables.st`) end up in the OPC UA address space. There are **19 nodes**:

- **9 process sensors:** `SensoreRD`, `SensoreASx`, `SensoreADx`, `SensoreSSx`, `SensoreSDx`, `SensoreIADx`, `SensoreIASx`, `SensoreITDx`, `SensoreITSx`
- **10 outputs:** the 9 `Comando*` actuator commands and `ComandoALLARME`

`SensoreSTART`, `SensoreRESET`, `SensoreEND` and the watchdog variables (`fbTimer`, `TimerWatchDog`, `TimerAct`) carry no pragma, so they are not published over OPC UA. The C# HMI accesses them over ADS.

## Two client paths to the same PLC

```
                 ADS (AMS 127.0.0.1.1.1:851)
  C# WinForms HMI  <--------------------------->  TwinCAT 3 PLC runtime (MAIN, SFC)
  (read/write, on-change notifications)                   ^
                                                          | ADS
                                                          |
  OPC UA clients   <--- opc.tcp://localhost:4840 --->  TwinCAT OPC UA Server
  (iFIX SCADA, read-only for Guests)                 (Data Access node manager PLC1)
```
