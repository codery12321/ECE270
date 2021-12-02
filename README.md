# ECE 270 Lab Experiment 4: Introduction to Verilog on a ice40HX8K FPGA
## Step 1: Light up LED segments with button presses
The figure above shows the named segments of the eight SS seven-segment displays present on the display. The pin numbers on the display are just for your information. The display is made up of seven segments, each with its own pin, as well as a decimal point (DP), also with its own segment. When you connect a pin for a segment to power (and add the necessary grounds) the segment will light up. <br />

You can write Verilog to do this. Write code to connect 7 buttons (pb[6:0]) to the seven segments of ss0. The decimal point is the 8th bit of the seven-segment display, but we will not be using that in this lab. If written correctly, pressing pb[0] will light up segment A, pb[1] will light up segment B, pb[2] will light up segment C, and so on. A demo animation is provided below. <br />

>Demonstrate the code you wrote to your TA to receive a checkoff. It should be on the FPGA, not the web simulator - the GIF provided above is merely intended to show you what the behavior should be on the FPGA.

## Step 2: Implement and verify a module for a bar graph display

In your top.sv file, create a new module named 'bargraph' that has two ports: <br />

- a 16-bit input bus port named 'in'
- and a 16-bit output bus port named 'out'

**Ensure that both ports are 'logic' type signals.**

Within the module, use dataflow assignments so that if in[n] is pressed, the bits out[n], out[n-1]... until out[0] are set to '1' (or a logic high). In other words, if in[15] is asserted, the bits out[15], out[14], out[13]... out[1], out[0] are all asserted. If in[8] is asserted, out[8], out[7]... out[1], out[0] are asserted, while out[15], out[14]... out[9] are all turned off. <br />

In the 'top' module, create an instance of the 'bargraph' module. You get to choose the instance name for it. Use name-based port connections. Connect pb[15:0] to the bargraph instance's 'in' port. Connect {left[7:0],right[7:0]} to the bargraph instance's 'out' port. (Study lecture 2-F carefully to learn how concatenations work.) <br />

The end result of this instantiation is that pressing the 'F' button will illuminate all 16 of the left and right LEDs, pressing the '0' button will illuminate only right[0], and any button between 'F' and '0' will turn on that number of LEDs + 1. <br />

The details of implementation of the 'bargraph' module is up to you. The suggested method of implementation is to use an OR expression for each of the 'out' elements. The out[0] output will be the result of the OR of 16 inputs. The out[1] output will be the result of an OR of 15 inputs. If you know how to use Verilog reduction operators, you may do so. If you don't, ask a TA. <br />


>Show your working design to a TA to receive a checkoff for this step. It should behave like the one above.

## Step 3: Implement a module for a 3-to-8 decoder

**Do not remove any of your code from the previous step.**
In your top.sv file, implement a 3-to-8 decoder in a manner similar to that described in lecture 2-F. The specifics for this decoder are:
- The name of the module should be 'decode3to8'.
- Outputs of the decoder module should be active-high.
- There is one 3-bit input port named 'in'.
- There is one 8-bit output port named 'out'.
- Ensure that both ports are of the 'logic' type.
- There is no enable line for this decoder. Therefore, exactly one of its outputs is always asserted.

The decoder should be constructed so that out[0] signal is asserted if and only if the in[2:0] bus value is 3'b000, the out[1] signal is asserted if and only if the in[2:0] bus value is 3'b001, and so on up to out[7]. Implementation details are left to you, but you might use the format in lecture 2-F as a guide. <br />

Create an instance of the 'decode3to8' module in your 'top' module. Use an instance name of your choosing. Make the following connections: <br />
- Connect pb[2:0] to the instances 'in' port.
- Connect each of the decimal points on the seven-segment displays (ss7, ... , ss0) to the 'out' port. The decimal point is element 7 of each of the ssx buses. You will need to concatenate element 7 of each bus into a single 8-bit bus connected to the 'out' port. You might need to think about this for a while.

The end result is that if no buttons are pressed, the decimal point of ss0 should be illuminated. If button 0 is pressed, to send a 3'b001 to the decoder input, the decimal point of ss1 should illuminate (and the decimal point of ss0 should turn off). If buttons '2', '1', and '0' are pressed, only the decimal point of ss7 should be illuminated.


>Show your working design to a TA to receive a checkoff for this step. It should behave like the one above.
