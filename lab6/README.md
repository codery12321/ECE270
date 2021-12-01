# Pre-Lab Submission 6

This lab is about implementing combinational building blocks. You will start by using the simulator to implement modules in SystemVerilog. Create a new workspace tab in the simulator called "lab6". Inside it, you will find a template.sv tab that contains a bare top module. Each new tab in the "lab6" workspace will create files named "newfile1.sv", "newfile2.sv", etc. You may use these names if you want to, but it would be better to rename them to something meaningful by pressing <shift>-mouse on the name. For instance, you might rename "template.sv" to "step1.sv". <br />

It is possible to put modules in two or more files of a workspace. When the simulator is in the "Workspace Simulation" mode, it combines the modules of all files together. In this experiment, however, we will treat each file separately, so be sure to switch from "Workspace Simulation" to "File Simulation". If you don't, you will see the warning message "ERROR Re-definition of module '\top'!" <br />

Follow the instructions for each exercise below. <br />

## Step 1: Implementing a 4-to-1 multiplexer in Verilog [10 points]

Create a new file in the "lab6" workspace and rename it "step1.sv". In the top module, create an instance of a 4-to-1 multiplexer like so: <br />
	`mux4to1 u1(.sel(pb[1:0]), .d(pb[7:4]), .y(green));` <br />
That is all you need to add to the top module. The goal of this exercise is to create a system that allows you to specify four values on buttons 7–4 and then select one of them with buttons 1 and 0. <br />

Immediately below the top module, create a module named mux4to1 with ports
- output logic y,
- input logic [3:0]d,
- input logic [1:0]sel,
<br /> In it, implement a 4-to-1 multiplexer. Use the example on page 22 of lecture 2-J as an example. You will have four 'd' inputs instead of eight and two 'sel' inputs instead of three, but the principle is the same.

If you prefer, you may also implement this using structural instantiations using the diagram on page 7 of the same lecture. This is the circuit that you will be physically constructing and testing. Part of the goal of the exercise is to gradually convince you that expression of a design with dataflow syntax is easier than using structural syntax. A careful reading of the lecture notes will lead you to an even more succinct implementation of a multiplexer.

Test your module well. Use <shift>-click on push buttons 7–4 to set the d[3:0] inputs to a persistent value. Then use buttons 1 and 0 to "select" one of those inputs. If buttons 7–4 are set to 1110, then pressing the 1 and 0 buttons as follows will show the result on the green LED:
```
sel[1]	sel[0]	green LED
0	0	0
0	1	1
1	0	1
1	1	1
```
And you can see that sel[1:0] are the inputs and green is the output for an OR function. Changing d[3:0] to 0110 would implement an XOR function. Any two-variable Boolean expression can be implemented with a 4-to-1 mux. This is why multiplexers are used in an FPGA. The FPGA we use for this course is filled with 16-to-1 multiplexers that can naturally implement any 4-variable Boolean expression. These "logic cells" can be interconnected to form extremely complex designs. <br />

When you have tested your design well, submit the file (including modules top and mux4to1) below. <br />

## Step 2: Implement a 16-to-4 basic encoder in Verilog [10 points]

Create a SystemVerilog file in the "lab6" workspace of the simulator. Rename it "step2.sv". In the top module create a single instance: <br />
	`enc16to4 u1(.in(pb[15:0]), .out(right[3:0]), .strobe(green));`  <br />
Below the top module, create a new module named enc16to4 with the following ports (in any order you like): <br />
- input logic [15:0] in
- output logic [3:0] out
- output logic strobe
Follow the pattern shown on pages 5–12 of lecture 2-i to build a basic encoder with sixteen inputs, four outputs, and a strobe output signal. When any single input is asserted, the strobe output should be asserted, and the binary encoding of the input. For instance, if in[5] is pressed, the strobe signal should be asserted, and the value of out[3:0] should be 4'b0101.  <br />

A basic encoder has a deficiency that multiple input assertions will result in a composite output. For instance, if in[5] and in[9] were asserted at the same time, the out signal will be 4'b1101 (which is the bitwise 'OR' of 4'b0101 and 4'b1001). We specifically want to see this behavior in your design.  <br />

To implement this module, set it up so that: <br />
- out[3] is 1 when any of in[15:8] are asserted
- out[2] is 1 when any of in[15:12] or in[7:4] are asserted
- out[1] is 1 when any of in[15:14], in[11:10], in[7:6], in[3:2], are asserted
- out[0] is 1 when any of the odd-numbered elements of in are asserted


 <br />To test your design, press any of the push buttons from 'F' – '0'. You should see the binary-encoded result on the four rightmost red LEDs. When any of those sixteen buttons are pressed, the green center LED should also light up. In a later exercise, you will have a more intuitive way of testing your encoder. <br />

When you have tested your design well, submit the file (including modules top and enc16to4) below. <br />

## Step 3: Implement a 16-to-4 priority encoder in Verilog [10 points]

Create a SystemVerilog file in the "lab6" workspace of the simulator. Rename it "step3.sv". In the top module create a single instance: <br />
	`prienc16to4 u1(.in(pb[15:0]), .out(right[3:0]), .strobe(green));`

Below the top module, create a new module named prienc16to4 with the following ports (in any order you like): <br />
- input logic [15:0] in
- output logic [3:0] out
- output logic strobe
Follow the pattern shown on pages 13–21 of lecture 2-i to build a priority encoder with sixteen inputs, four outputs, and a strobe output signal. When any single input is asserted, the strobe output should be asserted, and the binary encoding of the input. For instance, if in[5] is pressed, the strobe signal should be asserted, and the value of out[3:0] should be 4'b0101. <br />

A priority encoder overcomes the deficiency with multiple input assertions. For instance, if in[5] and in[9] were asserted at the same time, the out signal will be 4'b1001 since nine is greater than five. <br />

To implement this module, use the basic recipe shown on page 21 of lecture 2-i, and modify it to have a four-bit output. Be sure to use the port names listed above. <br />

To test your design, press any of the push buttons from 'F' – '0'. You should see the binary-encoded result on the four rightmost red LEDs. When any of those sixteen buttons are pressed, the green center LED should also light up. If you press two or more buttons simultaneously, the higher value button will determine the value output from the encoder. In a later exercise, you will have a more intuitive way of testing your encoder. <br />

When you have tested your design well, submit the file (including modules top and prienc16to4) below. <br />

# ECE 270 Lab Experiment 6: Combinational Building Blocks
##Introduction
An important part of hardware design is to be able to encapsulate and reuse code as ‘modules’ — specifically in Verilog. You have already learned about examples of such hardware modules in lecture, such as multiplexers, encoders and decoders. In this lab, you will practice implementing such building blocks and integrate them into an overall design. You will practice building a multiplexer with hardware to solidify your knowledge about this system in particular.

## Step 1: Implement a seven-segment decoder submodule in Verilog

Run the ece270-setup command again by double-clicking the shortcut on your desktop. A lab06 folder should now be added to the ece270 folder in your home directory. Inside it, open top.sv, and write a new module below the top module with the following specifications: <br />

From your prelab, copy the prienc16to4 module to your top.sv file, as you will use it to simplify testing for your ssdec module. <br />

- Module name: ssdec
- Module instance name: sd
  - This is very important! The module and instance names must match!
- Module ports:
  - in: 4-bit input port
  - enable: 1-bit input port
  - out: 7-bit output port
- Top module instance connections:
  - in: Connected to pb[3:0]
  - enable: Connected to 1'b1
  - out: Connected to ss0[6:0]

The module instance must start with:  <br />
`ssdec sd (...`

Follow the development shown on pages 11–26 of lecture 2-H to build a seven-segment display decoder. This module has four data inputs and a 7-bit output. It configures the outputs so that a four bit binary value is displayed as a hexadecimal digit on a 7-segment display. The third port, enable, determines if any of the outputs are asserted. If enable is not asserted, the output should remain off. This is a convenient way to turn off the entire digit if needed. <br />

The 7-bit output, when connected to one of ss0, ss1... ss6 or ss7 must look like this for the corresponding value of the input: <br />

       _         _    _         _    _    _    _    _    _         _         _    _
      | |    |   _|   _|  |_|  |_   |_     |  |_|  |_|  |_|  |_   |     _|  |_   |_  
      |_|    |  |_    _|    |   _|  |_|    |  |_|    |  | |  |_|  |_   |_|  |_   |   

Once you have written the submodule and instantiated it in the top module with the connections as explained above, test your design. Run "make cram" as you did for lab 4, correct any errors, and observe the behavior on the FPGA. Press any of the push buttons from 'F' – '0'. You should see the corresponding hexadecimal digit on the rightmost seven-segment display. <br />

Once that you have verified that your design is working for all combinations of pb[3:0], you can connect the input of your ssdec to the output of the priority encoder you wrote for your prelab (prienc16to4). Also connect the ssdec enable port to the strobe output of the decoder. (If you're confused about how to connect the ports of two separate instances, recall how to use an intermediate signal/bus to connect the ports). This will allow us to simply press one button (0 through F) to see the digit on the display. <br />

Demonstrate your new ssdec module to your TA to get checked off. Show that pressing 0 shows 0 on ss0, 1 shows 1, 2 shows 2, and so on. <br />
