/*****************************************************************************
 * Copyright (c) 2009-2010 Anoto AB. All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * Redistribution of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * Redistribution in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * Neither the name of Anoto AB nor the names of contributors may be used
 * to endorse or promote products derived from this software without
 * specific prior written permission.
 * This software is provided "AS IS," without a warranty of any kind. ALL
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING
 * ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. ANOTO AB AND ITS
 * LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A
 * RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS
 * DERIVATIVES. IN NO EVENT WILL ANOTO AB OR ITS LICENSORS BE LIABLE FOR
 * ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT, INDIRECT, SPECIAL,
 * CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND
 * REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR
 * INABILITY TO USE THIS SOFTWARE, EVEN IF ANOTO AB HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGES.
 ****************************************************************************/

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using Intel.UPNP;
using Intel.DeviceBuilder;
using System.Net.Sockets;
using System.Threading;
using System.Net;
using System.Collections; 

///<summary>
///This example shows how a C# application can access
///coordinates from Anoto devices using AnotoGenericStreamer
///</summary>

namespace Intel.DeviceBuilder
{
	public partial class Form1 : Form
	{
		private SampleDevice upnpDevice;
		// These delegates enable asynchronous calls for setting the values.
		delegate void AddAnotoDeviceCallback(string deviceSerial, AnotoGenericStreamer.PenType type, System.Drawing.Color c);
		delegate void RemoveAnotoDeviceCallback(string deviceSerial);
		delegate void DrawNewCoordCallback(string deviceSerial, int x, int y);

		const int BALLPOINT_BRUSH_WIDTH = 1; // the brush width for ballpoint tip type
		const int MARKER_BRUSH_WIDTH = 2;    // the brush width for marker tip type

		AnotoGenericStreamer.PenManagerClass gspm; // the PenManager class
		System.Collections.ArrayList anotoDevices; // list of connected devices
		System.Drawing.Graphics grBackground; // the background graphic
		int nextColor; // the next color to be used
		int imageWidth, imageHeight; // the size of the drawing area

		
		//tcp
		private TcpListener tcpListener;
    	private Thread listenThread;
    	private ArrayList ar_clients;

		public Form1()
		{
			InitializeComponent();

			// initialize
			nextColor = 0;
			imageWidth = this.pictureBox.Width;
			imageHeight = this.pictureBox.Height;
			// init drawing area
			ClearBackgroundImage();
			anotoDevices = new System.Collections.ArrayList();

			// create the AnotoGenericStreamer COM object
			gspm = new AnotoGenericStreamer.PenManagerClass();

			// register event handlers for AnotoGenericStreamer
			gspm.PenConnected += HandlePenConnected;
			gspm.PenDisconnected += HandlePenDisconnected;
			gspm.PenUp += HandlePenUp;
			gspm.PenDown += HandlePenDown;
			gspm.NewCoordinate += HandleNewCoordinate;
			gspm.PenDecodingStatus += HandlePenDecodingStatus;
			
			//tcp
			ar_clients = new ArrayList(); 
			this.tcpListener = new TcpListener(IPAddress.Any, 0);
     		this.listenThread = new Thread(new ThreadStart(ListenForClients));
      		this.listenThread.Start();
		}
		
		//TCP
		// Permet d'accepter les connexions entrantes
         public void ListenForClients()
         {
         	
 	 	this.tcpListener.Start();
             while (true)
			 {
		    //blocks until a client has connected to the server
		    TcpClient client = this.tcpListener.AcceptTcpClient();
		
		    
		    
		    //create a thread to handle communication
		    //with connected client
		    ar_clients.Add(client);
		    Thread clientThread = new Thread(new ParameterizedThreadStart(HandleClientComm));
		    clientThread.Start(client);
		    Console.WriteLine("tet"+client);
		  }
         }

		private void HandleClientComm(object client)
			{
			  TcpClient tcpClient = (TcpClient)client;
			  NetworkStream clientStream = tcpClient.GetStream();
			
			  byte[] message = new byte[4096];
			  int bytesRead;
			
			  while (true)
			  {
			    bytesRead = 0;
			
			    try
			    {
			      //blocks until a client sends a message
			      bytesRead = clientStream.Read(message, 0, 4096);
			    }
			    catch
			    {
			      //a socket error has occured
			      break;
			    }
			
			    if (bytesRead == 0)
			    {
			      //the client has disconnected from the server
			      break;
			    }
			
			    //message has successfully been received
			    ASCIIEncoding encoder = new ASCIIEncoding();
			    System.Diagnostics.Debug.WriteLine(encoder.GetString(message, 0, bytesRead));
			  }
		}
		
		
		public int getServerPort(){
			return 	((IPEndPoint)this.tcpListener.LocalEndpoint).Port;
		}
		public TcpListener getTcpListener(){
			return this.tcpListener;
		}
		
		public void SetDevice(SampleDevice d){
			upnpDevice = d;
		}

		/// <summary>
		/// Event handler for the Forms shown event
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		void Form1_Shown(object sender, System.EventArgs e)
		{
			// start the AnotoGenericStreamer when all subscriptions are setup
			gspm.Start();
		}

		/// <summary>
		/// Release memory allocated by AnotoGenericStreamer.
		/// Called from the Dispose function.
		/// </summary>
		private void ReleaseGenericStreamer()
		{
			gspm.Stop();
		}

		#region Generic Streamer event handlers

		/// <summary>
		/// A new anoto device has been connected
		/// </summary>
		/// <param name="deviceSerial">The device serial number</param>
		/// <param name="type">The type</param>
		/// <param name="time">The timestamp</param>
		/// <param name="productName">The product name</param>
		/// <param name="pid">The product id</param>
		public void HandlePenConnected(string deviceSerial, AnotoGenericStreamer.PenType type,
                                   ulong time, string productName, ushort pid)
		{
			// add the new connected device to the list of connected devices
			AddAnotoDevice(deviceSerial, type, GetDeviceColor());
			//TCP
			ArrayList ar_clientsUpdate = new ArrayList();
			bool change = false; 
			foreach(TcpClient tcpClient in ar_clients)
			{
			 	try{
				 	//Console.WriteLine("client emission");
					NetworkStream clientStream = tcpClient.GetStream();
					ASCIIEncoding encoder = new ASCIIEncoding();
					byte[] buffer = encoder.GetBytes("|serial:"+deviceSerial+":event:PenConnected"+";" );
					
					clientStream.Write(buffer, 0 , buffer.Length);
					clientStream.Flush();
					ar_clientsUpdate.Add(tcpClient);
			 	}
			 	catch(Exception e){
				 	Console.WriteLine(e);
				 	change = true;
			 	}
			 }
			 if(change){
			 	ar_clients = ar_clientsUpdate;
			 }
		}

		/// <summary>
		/// An anoto device has disconnected
		/// </summary>
		/// <param name="deviceSerial">The device serial number</param>
		/// <param name="type">The type</param>
		/// <param name="time">The timestamp</param>
		public void HandlePenDisconnected(string deviceSerial, AnotoGenericStreamer.PenType type,
                                      ulong time)
		{
			// remove the device from the list of connected devices
			RemoveAnotoDevice(deviceSerial);
			//TCP
			ArrayList ar_clientsUpdate = new ArrayList();
			bool change = false;
			 foreach(TcpClient tcpClient in ar_clients)
			 {
			 	try{
				 	//Console.WriteLine("client emission");
					NetworkStream clientStream = tcpClient.GetStream();
					ASCIIEncoding encoder = new ASCIIEncoding();
					byte[] buffer = encoder.GetBytes("|serial:"+deviceSerial+":event:PenDisconnected"+";" );
					
					clientStream.Write(buffer, 0 , buffer.Length);
					clientStream.Flush();
					ar_clientsUpdate.Add(tcpClient);
			 	}
			 	catch(Exception e){
				 	Console.WriteLine(e);
				 	change = true;
			 	}
			 }
			 if(change){
			 	ar_clients = ar_clientsUpdate;
			 }
		}

		/// <summary>
		/// An anoto device has been lifted from the anoto pattern
		/// </summary>
		/// <param name="deviceSerial">The device serial number</param>
		/// <param name="type">The type</param>
		/// <param name="time">The timestamp</param>
		/// <param name="penDownSeqNbr">The penDown sequence number</param>
		/// <param name="isSpcdGenerated">true, if SPCD has generated this event.\n
		/// false, if this event is due to an event from the device</param>
		public void HandlePenUp(string deviceSerial, AnotoGenericStreamer.PenType type,
                            ulong time, byte penDownSeqNbr, bool isSpcdGenerated)
		{
			AnotoDevice anotoDevice = GetAnotoDevice(deviceSerial);
			anotoDevice.down = false;
			
			//TCP
			ArrayList ar_clientsUpdate = new ArrayList();
			bool change = false;
			 foreach(TcpClient tcpClient in ar_clients)
			 {
			 	try{
				 	//Console.WriteLine("client emission");
					NetworkStream clientStream = tcpClient.GetStream();
					ASCIIEncoding encoder = new ASCIIEncoding();
					byte[] buffer = encoder.GetBytes("|serial:"+deviceSerial+":event:PenUp"+";" );
					
					clientStream.Write(buffer, 0 , buffer.Length);
					clientStream.Flush();
					ar_clientsUpdate.Add(tcpClient);
			 	}
			 	catch(Exception e){
				 	Console.WriteLine(e);
				 	change = true;
			 	}
			 }
			 if(change){
			 	ar_clients = ar_clientsUpdate;
			 }
		}

		/// <summary>
		/// The tip of an anoto device is down
		/// </summary>
		/// <param name="deviceSerial">The device serial number</param>
		/// <param name="type">The type</param>
		/// <param name="time">The timestamp</param>
		/// <param name="penDownSeqNbr">The penDown sequence number</param>
		/// <param name="tipType">The tip type of the pen</param>
		/// <param name="isValidColor">true, if the r, g, b values is valid.\n
		/// false, if the r, g, b values is invalid and should not be used</param>
		/// <param name="r">The r value of the current device color</param>
		/// <param name="g">The g value of the current device color</param>
		/// <param name="b">The b value of the current device color</param>
		/// <param name="isSpcdGenerated">true, if SPCD has generated this event.\n
		/// false, if this event is due to an event from the device</param>
		public void HandlePenDown(string deviceSerial, AnotoGenericStreamer.PenType type,
                              ulong time, byte penDownSeqNbr,
                              AnotoGenericStreamer.PenTipType tipType, bool isValidColor,
                              byte r, byte g, byte b, bool isSpcdGenerated)
		{
			AnotoDevice anotoDevice = GetAnotoDevice(deviceSerial);

			// right now, only ADP501 supports device color
			if (type == AnotoGenericStreamer.PenType.ADP_501 && isValidColor)
			{
				anotoDevice.setColor(System.Drawing.Color.FromArgb(r, g, b));
			}
			
			//TCP
			ArrayList ar_clientsUpdate = new ArrayList();
			bool change = false;
			 foreach(TcpClient tcpClient in ar_clients)
			 {
			 	try{
				 	//Console.WriteLine("client emission");
					NetworkStream clientStream = tcpClient.GetStream();
					ASCIIEncoding encoder = new ASCIIEncoding();
					byte[] buffer = encoder.GetBytes("|serial:"+deviceSerial+":event:PenDown"+";" );
					
					clientStream.Write(buffer, 0 , buffer.Length);
					clientStream.Flush();
					ar_clientsUpdate.Add(tcpClient);
			 	}
			 	catch(Exception e){
				 	Console.WriteLine(e);
				 	change = true;
			 	}
			 }
			 if(change){
			 	ar_clients = ar_clientsUpdate;
			 }

			anotoDevice.setTipType(tipType);
		}

		/// <summary>
		/// A device has sent a coordinate event.
		/// </summary>
		/// <param name="deviceSerial">The device serial number</param>
		/// <param name="type">The type</param>
		/// <param name="time">The timestamp</param>
		/// <param name="page">The page address the coordinate belongs to</param>
		/// <param name="x">The x application coordinate in anoto units</param>
		/// <param name="y">The x application coordinate in anoto units</param>
		/// <param name="imgSeqNbr">The image sequence number</param>
		/// <param name="force">The device tip force</param>
		public void HandleNewCoordinate(string deviceSerial, AnotoGenericStreamer.PenType type,
                                    ulong time, string page, int x, int y,
                                    byte imgSeqNbr, byte force)
		{
			
		//Console.WriteLine("serial"+deviceSerial);
			//Console.WriteLine("page"+page);
			//Console.WriteLine("force"+force);
			//Console.WriteLine("x:"+x+"  y:"+y);
			upnpDevice.ImportedService_setSerial(deviceSerial);
			upnpDevice.ImportedService_setPage(page);
			upnpDevice.ImportedService_setForce(force);
			upnpDevice.ImportedService_setX(x);
			upnpDevice.ImportedService_setY(y);
			//DrawNewCoord(deviceSerial, x, y);
			
			//TCP
			ArrayList ar_clientsUpdate = new ArrayList();
			bool change = false;
			 foreach(TcpClient tcpClient in ar_clients)
			 {
			 	try{
				 	Console.WriteLine("client emission");
					NetworkStream clientStream = tcpClient.GetStream();
					ASCIIEncoding encoder = new ASCIIEncoding();
					byte[] buffer = encoder.GetBytes("|serial:"+deviceSerial+":page:"+page+":force:"+force+":x:"+x+":y:"+y+";" );
					
					clientStream.Write(buffer, 0 , buffer.Length);
					clientStream.Flush();
					ar_clientsUpdate.Add(tcpClient);
			 	}
			 	catch(Exception e){
				 	Console.WriteLine(e);
				 	change = true;
			 	}
			 }
			 if(change){
			 	ar_clients = ar_clientsUpdate;
			 }
			
		}

		/// <summary>
		/// A decoding error has occurred.
		/// </summary>
		/// <param name="deviceSerial">The device serial number</param>
		/// <param name="type">The type</param>
		/// <param name="time">The timestamp</param>
		/// <param name="imgSeqNbr">The image sequence number</param>
		/// <param name="decodingStatusType">The type of occurred decoding error</param>
		public void HandlePenDecodingStatus(string deviceSerial, AnotoGenericStreamer.PenType type,
                                        ulong time, byte imgSeqNbr,
                                        AnotoGenericStreamer.DecodingStatusType decodingStatusType)
		{
			// write the decoding status to the console
			//Console.WriteLine("Decoding status: " + decodingStatusType.ToString());
		}

		#endregion //Generic Streamer event handlers

		#region methods to manipulate the anotoDevice collection

		/// <summary>
		/// Add a new device to the list of connected devices
		/// </summary>
		/// <param name="deviceSerial">The serial number</param>
		/// <param name="type">The type</param>
		/// <param name="c">The color to use if rendering data from the device</param>
		private void AddAnotoDevice(string deviceSerial, AnotoGenericStreamer.PenType type,
                                System.Drawing.Color c)
		{
			if (this.ConnectedDevListView.InvokeRequired)
			{
				AddAnotoDeviceCallback d = new AddAnotoDeviceCallback(AddAnotoDevice);
				this.Invoke(d, new object[] { deviceSerial, type, c });
			}
			else
			{
				// create a new object of AnotoDevice and initialize with 
				// the specified information
				AnotoDevice newDevice = new AnotoDevice(deviceSerial, type, c);
				ListViewItem newItem;
				int imageIndex = 1; // default image index is 1

				// add the anoto device object to the list of connected devices
				anotoDevices.Add(newDevice);

				// add to list view (show an icon)
				// we have a nice image of DP-201, use a default image for the rest
				if (type == AnotoGenericStreamer.PenType.DP_201)
				{
					imageIndex = 0;
				}
				// add the device to the ConnectedDevListView
				newItem = ConnectedDevListView.Items.Add(deviceSerial, deviceSerial, imageIndex);
			}
		}

		/// <summary>
		/// Remove a device from the list of connected devices
		/// </summary>
		/// <param name="deviceSerial">The device serial number</param>
		private void RemoveAnotoDevice(string deviceSerial)
		{
			if (this.ConnectedDevListView.InvokeRequired)
			{
				RemoveAnotoDeviceCallback d = new RemoveAnotoDeviceCallback(RemoveAnotoDevice);
				this.Invoke(d, new object[] { deviceSerial });
			}
			else
			{
				// search the list for a device with the matching serial number
				foreach (AnotoDevice d in anotoDevices)
				{
					if (d.deviceSerial == deviceSerial)
					{
						// remove it
						anotoDevices.Remove(d);
						break;
					}
				}

				// remove from list view
				ConnectedDevListView.Items.RemoveByKey(deviceSerial);
			}
		}

		/// <summary>
		/// Get the anoto device with the specified serial number
		/// </summary>
		/// <param name="deviceSerial">The device serial number</param>
		/// <returns>The matching device or null if not found</returns>
		private AnotoDevice GetAnotoDevice(string deviceSerial)
		{
			AnotoDevice anotoDevice = null;

			// search the list for a device with the matching serial number
			foreach (AnotoDevice d in anotoDevices)
			{
				if (d.deviceSerial == deviceSerial)
				{
					// found it
					anotoDevice = d;
					break;
				}
			}

			return anotoDevice;
		}

		#endregion //methods to manipulate the anotoDevice collection

		/// <summary>
		/// Update the drawing area with the new coordinate
		/// </summary>
		/// <param name="deviceSerial">The device serial number</param>
		/// <param name="x">The x application coordinate in anoto units</param>
		/// <param name="y">The y application coordinate in anoto units</param>
		/// <param name="force"></param>
		private void DrawNewCoord(string deviceSerial, int x, int y)
		{
			// check if invoke is required
			if (this.pictureBox.InvokeRequired)
			{
				DrawNewCoordCallback d = new DrawNewCoordCallback(DrawNewCoord);
				this.Invoke(d, new object[] { deviceSerial, x, y });
			}
			else
			{
				// scale
				int sX = (int)(x * this.imageWidth / 7650);
				int sY = (int)(y * this.imageWidth / 7650);

				// get the anoto device with the specified device serial number
				AnotoDevice anotoDevice = GetAnotoDevice(deviceSerial);

				if (anotoDevice != null)
				{
					if (!anotoDevice.down)
					{
						anotoDevice.currentX = sX;
						anotoDevice.currentY = sY;
						anotoDevice.down = true;
					}
					else
					{
						try
						{
							int penWidth = BALLPOINT_BRUSH_WIDTH; // default

							// use different pen width depending on the tip type
							if (anotoDevice.tipType == AnotoGenericStreamer.PenTipType.MARKER)
							{
								penWidth = MARKER_BRUSH_WIDTH;
							}

							// draw a line between the two coordinates
							System.Drawing.Pen pen = new System.Drawing.Pen(anotoDevice.color, penWidth);
							Point point1 = new Point(anotoDevice.currentX, anotoDevice.currentY);
							Point point2 = new Point(sX, sY);
							grBackground.DrawLine(pen, point1, point2);
							pen.Dispose();

							// update current position (drawing area coordinates)
							anotoDevice.currentX = sX;
							anotoDevice.currentY = sY;
							anotoDevice.down = true;

							// tell Windows which region that actually needs repainting
							int x1 = Math.Min(point1.X, point2.X) - 1;
							int y1 = Math.Min(point1.Y, point2.Y) - 1;
							int x2 = Math.Max(point1.X, point2.X) + 1;
							int y2 = Math.Max(point1.Y, point2.Y) + 1;
							Rectangle boundingBox = new Rectangle(x1, y1, x2 - x1, y2 - y1);
							this.pictureBox.Invalidate(boundingBox);
						}
						catch (Exception e)
						{
							//Console.WriteLine("Exception: (drawNewCoord)" + e.Message);
						}
					}

				}
				else
				{
					Console.WriteLine("No matching Anoto device found");
				}
			}
		}
		
		/// <summary>
		/// Select a color for the device
		/// </summary>
		/// <returns>The next color</returns>
		System.Drawing.Color GetDeviceColor()
		{
			System.Drawing.Color c;
			switch (nextColor)
			{
				case 0:
					c = Color.Red;
					break;
				case 1:
					c = Color.Blue;
					break;
				case 2:
					c = Color.Green;
					break;
				case 3:
					c = Color.Black;
					break;
				default:
					nextColor = 0;
					c = Color.Red;
					break;
			}
			nextColor++;
			return c;
		}

		/// <summary>
		/// Clear the background
		/// </summary>
		private void ClearBackgroundImage()
		{
			if (null != grBackground)
			{
				grBackground.Dispose();
			}
			this.pictureBox.BackgroundImage = new Bitmap(this.imageWidth, this.imageHeight);
			grBackground = Graphics.FromImage(this.pictureBox.BackgroundImage);
			grBackground.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
		}

		/// <summary>
		/// Show a message box with license information
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void aboutMnu_Click(object sender, EventArgs e)
		{
			string version = "";
			string aText;

			// get the current version of SimpleStreamer
			try
			{
				System.Reflection.Assembly asm = System.Reflection.Assembly.GetExecutingAssembly();
				version = asm.GetName().Version.ToString();
			}
			catch (Exception ex)
			{
				//Console.WriteLine("GetFileVersion failed " + ex.Message);
			}

			aText = "SimpleStreamer version " + version + "\n\n" +
					"Copyright © 2009 - 2010 Anoto AB and its licensors." + "\n" +
					"All rights reserved." + "\n\n" +
					"\"Anoto\", \"Magic Box\" and the Anoto logotype are trademarks" + "\n" +
					"owned by Anoto AB. All other trademarks are the property of" + "\n" +
					"their respective owners." + "\n\n" +
					"This software is based on Anoto Digital Pen and Paper Technology," + "\n" +
					"which is covered by over 200 patents worldwide, including but not" + "\n" +
					"limited to US6663008, US7172131, US7248250, US7281668," + "\n" +
					"JP3872498, JP3842283, CN1595440, SE517445, RU2256225," + "\n" +
					"and AU773011." + "\n\n" +
					"Refer to the separate license agreement accepted at the installation of" + "\n" +
					"this software for usage terms and conditions. Notices and additional usage" + "\n" +
					"terms and conditions pertaining to third party material included in this" + "\n" +
					"software may be found in a \"Read Me\" file that came with the installation" + "\n" +
					"of this software.";

			MessageBox.Show(aText, "About");
		}

		/// <summary>
		/// The user has clicked on the Exit menu. Exit this
		/// application.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void exitMnu_Click(object sender, EventArgs e)
		{
			// exit and cleanup memory. Dispose() in Form1.Designer.cs
			// calls gspm.stop()
			Dispose(true);
		}

		/// <summary>
		/// The user has clicked on the Clear button. Clear the background.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void clearBtn_Click(object sender, EventArgs e)
		{
			ClearBackgroundImage();
		}
	}
}
