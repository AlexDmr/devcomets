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
using System.Text;

namespace Intel.DeviceBuilder
{
	/// <summary>
	/// This class represents an anoto device.
	/// </summary>
	class AnotoDevice
	{
		public string deviceSerial; // the device serial number
		public int currentX, currentY; // current drawing area coordinates
		public bool down;
		public System.Drawing.Color color; // the color to use when rendering data from this device
		public AnotoGenericStreamer.PenType deviceType; // the type of device
		public AnotoGenericStreamer.PenTipType tipType; // ballpoint, marker, etc

		public AnotoDevice(string deviceSerial, AnotoGenericStreamer.PenType type, System.Drawing.Color c)
		{
			this.deviceSerial = deviceSerial;
			deviceType = type;
			tipType = AnotoGenericStreamer.PenTipType.UNKNOWN;
			currentX = 0;
			currentY = 0;
			color = c;
			down = false;
		}

		/// <summary>
		/// Set the color to use when rendering data from the device
		/// </summary>
		/// <param name="c"></param>
		public void setColor(System.Drawing.Color c)
		{
			color = c;
		}

		/// <summary>
		/// Set the tip type of the device
		/// </summary>
		/// <param name="tipType"></param>
		public void setTipType(AnotoGenericStreamer.PenTipType tipType)
		{
			this.tipType = tipType;
		}
	}
}
