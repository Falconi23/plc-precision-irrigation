// ADS client part of the WinForms HMI (TesinaRespa/Form1.cs, TwinCAT.Ads), which also simulates the plant sensors.
// Omitted: field animation (MasterTimer_Tick), restart/end/pause buttons, designer code; repeated per-variable
// lines are elided where marked with "...". UI strings translated from Italian.

using System;
using System.Windows.Forms;
using TwinCAT.Ads;

namespace TesinaRespa
{
    // PLC -> HMI via on-change notifications into bound TextBoxes; HMI -> PLC via
    // TextChanged handlers calling WriteAny, so simulated sensors look like real inputs.
    public partial class Form1 : Form
    {
        TcAdsClient tcClient;
        int[] hConnect;            // notification handles, one per PLC variable
        AdsStream dataStream;      // shared by all notifications
        AdsBinaryReader binRead;

        int NUM_ELEMENTS_BOOL = 22;   // 12 sensors + 9 commands + alarm
        int NUM_ELEMENTS_TIME = 2;    // TimerWatchDog, TimerAct
        int[] hvar_name;              // handles for writes

        // Indices below are used everywhere else in the form.
        string[] dataPLC = {
            "MAIN.SensoreSTART",            //0
            "MAIN.SensoreRESET",            //1
            "MAIN.SensoreEND",              //2
            "MAIN.SensoreRD",               //3
            "MAIN.SensoreASx",              //4
            "MAIN.SensoreADx",              //5
            "MAIN.SensoreSSx",              //6
            "MAIN.SensoreSDx",              //7
            "MAIN.SensoreIADx",             //8
            "MAIN.SensoreIASx",             //9
            "MAIN.SensoreITDx",             //10
            "MAIN.SensoreITSx",             //11
            "MAIN.ComandoPioggiaMoveDown",  //12
            "MAIN.ComandoAraturaSx",        //13
            "MAIN.ComandoAraturaDx",        //14
            "MAIN.ComandoSeminaSx",         //15
            "MAIN.ComandoSeminaDx",         //16
            "MAIN.ComandoIrrigazioneAutoDx",//17
            "MAIN.ComandoIrrigazioneAutoSx",//18
            "MAIN.ComandoIrrigazioneTuboDx",//19
            "MAIN.ComandoIrrigazioneTuboSx",//20
            "MAIN.ComandoALLARME",          //21
            "MAIN.TimerWatchDog",           //22
            "MAIN.TimerAct"                 //23
        };

        // Connect
        private void button1_Click(object sender, EventArgs e)
        {
            tcClient = new TcAdsClient();

            // Local runtime AMS Net ID, port 851 = first PLC runtime.
            tcClient.Connect("127.0.0.1.1.1", 851);

            // 1 byte per BOOL, 4 per TIME (32-bit milliseconds).
            dataStream = new AdsStream(NUM_ELEMENTS_BOOL + NUM_ELEMENTS_TIME * 4);
            binRead = new AdsBinaryReader(dataStream);

            hConnect = new int[NUM_ELEMENTS_BOOL + NUM_ELEMENTS_TIME];

            try
            {
                // Args: symbol, stream, offset, length, mode, cycle [ms], max delay, userData (the bound TextBox).
                hConnect[0] = tcClient.AddDeviceNotification(dataPLC[0], dataStream, 0, 1, AdsTransMode.OnChange, 100, 0, SensoreSTART);
                hConnect[1] = tcClient.AddDeviceNotification(dataPLC[1], dataStream, 1, 1, AdsTransMode.OnChange, 100, 0, SensoreRESET);
                // ... indices 2..20 elided, same pattern ...
                hConnect[21] = tcClient.AddDeviceNotification(dataPLC[21], dataStream, 21, 1, AdsTransMode.OnChange, 100, 0, Allarme);
                hConnect[22] = tcClient.AddDeviceNotification(dataPLC[22], dataStream, 22, 4, AdsTransMode.OnChange, 100, 0, TWatchDog);
                hConnect[23] = tcClient.AddDeviceNotification(dataPLC[23], dataStream, 26, 4, AdsTransMode.OnChange, 100, 0, TAct);

                tcClient.AdsNotification += new AdsNotificationEventHandler(OnNotification);

                ConnText.Text = "Connection established";
            }
            catch (Exception err)
            {
                ConnText.Text = err.Message.ToString();
            }

            hvar_name = new int[NUM_ELEMENTS_BOOL + NUM_ELEMENTS_TIME];
            for (int i = 0; i < NUM_ELEMENTS_BOOL + NUM_ELEMENTS_TIME; i++)
            {
                hvar_name[i] = tcClient.CreateVariableHandle(dataPLC[i]);
            }
        }

        private void OnNotification(object sender, AdsNotificationEventArgs e)
        {
            string strValue = "";

            if (e.NotificationHandle == hConnect[0])
                strValue = binRead.ReadBoolean().ToString();
            else if (e.NotificationHandle == hConnect[1])
                strValue = binRead.ReadBoolean().ToString();
            // ... BOOL branches for hConnect[2]..hConnect[21] elided ...
            else if (e.NotificationHandle == hConnect[22])
                strValue = binRead.ReadInt32().ToString();   // TIME as ms
            else if (e.NotificationHandle == hConnect[23])
                strValue = binRead.ReadInt32().ToString();

            // Notifications arrive on an ADS thread.
            ((TextBox)e.UserData).Invoke(new Action(() => ((TextBox)e.UserData).Text = String.Format(strValue)));

            // START set on the PLC side also starts the animation.
            if (SensoreSTART.Text.Equals("True"))
            {
                this.MasterTimer.Enabled = true;
            }
        }

        // One write-back handler per variable, all with this shape.
        private void SensoreSTART_TextChanged(object sender, EventArgs e)
        {
            if (hvar_name != null)   // not connected yet
            {
                if (SensoreSTART.Text.Equals("True"))
                {
                    tcClient.WriteAny(hvar_name[0], true);
                }
                if (SensoreSTART.Text.Equals("False"))
                {
                    tcClient.WriteAny(hvar_name[0], false);
                }
            }
        }

        // Watchdog preset in ms.
        private void TWatchDog_TextChanged(object sender, EventArgs e)
        {
            if (hvar_name != null)
            {
                if (!TWatchDog.Text.Equals(""))
                {
                    tcClient.WriteAny(hvar_name[22], int.Parse(TWatchDog.Text));
                }
            }
        }

        private void StartButton_Click(object sender, EventArgs e)
        {
            MasterTimer.Enabled = true;
            SensoreSTART.Text = "True";    // fires TRANS0
            SensoreRESET.Text = "False";

            MessageBox.Show("Process started!");

            // The HMI, not the PLC, picks the irrigation arm: IADx -> TRANS6 (tanker), ITDx -> TRANS9 (hose).
            Random random = new Random();
            int num = random.Next(0, 2);

            if (num == 1)
            {
                SensoreIADx.Text = "True";
                SensoreITDx.Text = "False";
            }
            else
            {
                SensoreITDx.Text = "True";
                SensoreIADx.Text = "False";
            }
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            tcClient.Dispose();
        }
    }
}
