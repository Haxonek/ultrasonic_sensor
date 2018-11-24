import math


def generate_signal(data):

	bit_duration = .2*.001; # seconds

	# high = 1 bit, low = 0 bit
	hf = 22000;
	lf = 21000;

	preamble = [.5, 1, 0, 1, .5];
	header = [0, 0, 1];

	packet = [preamble + header + data];

	print(packet)

	# convert into frequencies (Hz)
	for i in 1:length(packet):
		packet[i] = ( abs(hf - lf) * packet[i] ) + lf;

	phase = 0;







def __init__():
	print("Starting \n")
	generate_signal([0,1,0])


generate_signal([0,1,0])
