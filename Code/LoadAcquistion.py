from Phidget22.Phidget import *
from Phidget22.Devices.VoltageRatioInput import *
import time

f = open("ScaleCollection.txt", "a")
f.write("\nNew Set of weights")
gain = float(-11409.178144114)
offset = float(-7.5184E-004)

def onVoltageRatioChange(self, voltageRatio):
	L = float(voltageRatio + offset)*gain # mAY NEED A FIX HERE
	f.write("\n {}".format(str(L)))
	print("VoltageRatio: " + str(voltageRatio))
	print("Weight: " + str(L))

def main():
	
	voltageRatioInput0 = VoltageRatioInput()
	voltageRatioInput0.setOnVoltageRatioChangeHandler(onVoltageRatioChange)
	voltageRatioInput0.openWaitForAttachment(5000)
		
	try:
		input("Press Enter to Stop\n")
	except (Exception, KeyboardInterrupt):
		pass
	
	voltageRatioInput0.close()

main()
