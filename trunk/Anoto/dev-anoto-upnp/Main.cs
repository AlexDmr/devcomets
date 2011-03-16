// Intel's UPnP .NET Framework Device Stack, Core Module
// Intel Device Builder Build#1.0.1868.18043

using System;
using System.Collections.Generic;
using System.Windows.Forms;
using Intel.UPNP;
using Intel.DeviceBuilder;

namespace Intel.DeviceBuilder
{
	/// <summary>
	/// Summary description for Main.
	/// </summary>
	class SampleDeviceMain
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{
			// Starting UPnP Device
			System.Console.WriteLine("Intel's UPnP .NET Framework Stack");
			System.Console.WriteLine("Intel Device Builder Build#1.0.1868.18043");
			SampleDevice device = new SampleDevice();
			device.Start();
			System.Console.WriteLine("Press return to stop device.");
			Application.EnableVisualStyles();
			Application.SetCompatibleTextRenderingDefault(false);
			Form1 form = new Form1();
			form.SetDevice(device);
			device.setTcpListener(form.getTcpListener());
			device.setTcpServerPort(form.getServerPort());
			Application.Run(form);
			System.Console.ReadLine();
			device.Stop();
			Console.WriteLine("end");
		}
		
	}
}

