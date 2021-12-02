## Step 7: ring8 [20 points]

Write a Verilog module named ring8 that implements the Moore machine shown in the diagram above. You should instantiate it in the standard Verilog simulator top module as follows:

  `ring8 r(.CLK(pb[1]), .S(pb[2]), .RESET(reset), .Q(right[7:5]), .X(right[4]), .Y(right[3]), .QN(right[2:0]));`

Where CLK, S and RESET are single-bit input logic signals, Q and QN are 3-bit logic outputs that represent the current state and the next-state, and X and Y are single-bit logic outputs that represent the X and Y states. The RESET signal should act as an asynchronous reset. <br />

The end result will allow you to reset the state machine back to the 000 state when you press 3-0-W, and the '1' button will advance the state machine to the next state depending on the value of S, which is entered with the '2' button. The right LEDs will show the values of the current state, the current outputs for the state (X,Y), and the next state. <br />

Hey, this would have been very useful for generating the answers to the last few questions. Agreed! It's not too late to check your work! When you're done, copy and paste only the ring8 module into the box below. <br />

## Step 11: A sequence recognizer [20 points]
Consider the [state machine](statemachine.png): <br />

From the reset state (000), it will recognize values on 'S' clocked into the state machine. When one of them is recognized, it will activate the 'G' (green) signal and remain in that state regardless of further inputs until it is reset back to the start state. When a bad input is recognized, it will be forced into the error state where it will activate the 'R' (red) signal and remain in that state regardless of further inputs until it is reset back to the start state. <br />

An example of "good" inputs are as follows: <br />
```
	1 0 1 0
	0 0 0 0 0 0 0 ... 0 0 0 1 0 1 0
	1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 0
```
In other words, any number of leading zeros, followed by any number of repetitions of 1 0 1, followed by 0. A "bad" input are as follows: <br />
```
	1 1
	0 0 0 0 0 0 0 ... 0 0 0 1 1
	1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1 1
```
In other words, one or more leading zeros followed by 1 1, or 1 0 0, followed by any number of repetitions of 1 0 1 followed by a 1. <br />

Implement it as a Verilog module named redgreen so that it can be instantiated into the standard Verilog simulator top module as follows: <br />

  `redgreen rg(.CLK(pb[1]), .RESET(reset), .S(pb[2]), .R(red), .G(green), .Q(right[7:5]), .QN(right[2:0]));`

Where CLK, RESET, and S are single bit input logic signals that represent the clock, asynchronous reset, and S inputs. R and G are the red and green outputs. Q and QN are the current state and next state outputs. <br />

Test your module carefully. When you are satisfied that it works correctly, copy and paste only the redgreen module in the text box below. <br />
