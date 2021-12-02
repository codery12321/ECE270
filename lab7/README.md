# Pre-Lab Submission 7:
## Step 4: Instantiate structural flip-flops in Verilog [10 points]

Next, you will simulate a ring counter using Verilog. Let's do so in a manner more similar to how you will construct your lab experiment. In your lab experiment, you will use two 74HC74 dual-D-type flip-flops. Each of these chips contains two flip-flops. Each of those flip-flops has an active-low asynchronous reset (also called "clear") and an active-low asynchronous set (also called "preset"). <br />

Although a Verilog simulator can model any kind of logic, the Verilog simulator is strictly limited to disallow anything not supported by the FPGA we use for the class. For reasons we won't go over until lecture 3-E, our simulator will not allow a flip-flop with both a reset and a set. (Read ahead to that lecture if you want.) Each flip-flop can have either a reset or a set. <br />

We will use the two models provided for the 74HC74 in the course References directory. One of them has an active-low reset 'rn' and the other has an active-low set 'sn'. Each one has 'd', 'c', 'q', and 'qn' lines for the data input, clock input, Q output and inverted output, respectively. You can see the implementation of these modules as well. There are Verilog constructs that you likely have not seen before. You will start to learn about them in lecture 3-E. For now, you can just use each model as an "opaque" box. <br />

For this exercise, create a new simulator workspace named "lab7". Rename the default file tab from "template.sv" to "prelab4.sv". Start with the standard top module provided by the simulator. Append the module definitions for hc74_reset and hc74_set below top. <br />

In the top module, create an instance of hc74_reset and connect its clock to pb[0], connect its data input to pb[1], and connect its non-inverted output (q) to right[0]. Connect its active-low asynchronous reset (rn) to the 'W' button (pb[16]). Use <shift>-click to press and hold the 'W' button to make sure pb[16] is high. With this, you have a system where the right[0] LED illuminates after a rising edge of the clock (0 button) when the '1' button is held down. If the right[0] is on, it is cleared the instant the 'W' button is released. This is the nature of an active-low reset. <br />

Next, in the top module, create an instance of hc74_set and connect its clock to pb[0], connect its data input to pb[1], and connect its non-inverted output (q) to right[1]. Connect its active-low asynchronous set (sn) to the 'W' button (pb[16]). Use <shift>-click to press and hold the 'W' button to make sure pb[16] is high. With this, you have a system where the right[1] LED illuminates after a rising edge of the clock (0 button) when the '1' button is held down. If the right[1] is off, it is set the instant the 'W' button is released. This is the nature of an active-low set. <br />

Test your system throroughly. Submit all three modules in the textbox below. <br />

## Step 5: Create a 4-bit ring counter in Verilog [10 points]

Next, create a new file tab in the "lab7" workspace. (Make sure that you have "File simulation" selected rather than "Workspace simulation"!) Call the new file "prelab5.sv". In it, you will again start with the standard top module, add the hc74_reset and hc74_set modules, and then modify the contents of the top module. <br />

In the top module, create a single instance of the 74hc_set module and three instances of the 74hc_reset module. Use whatever additional signals you need to create a ring counter similar to step 3, above. The active-low asynchronous set and reset ports should be connected to the 'W' button. The clock port on each flip-flop should be connected to the '0' button. The 'q' outputs of the flip-flops should be connected to right[3:0]. The system should work as follows: <br />

- When the 'W' button is released (pb[16] goes low), the right[0] LED should light. The right[3:1] LEDs should turn off. This means that the flip-flop with the set/preset port should have its 'q' output connected to right[0]. All the flip-flops with reset/clear ports should be connected to right[3:2].
- While the 'W' button is held down (pb[16] remains high), each rising edge of the clock (pb[0]) will cause the next LED to the left to light up. This is to say, the pattern on right[3:0] should advance like so: <br />
	0001
	0010
	0100
	1000
	0001
	0010
	...
Once you have thoroughly tested your Verilog design, submit all three modules in the text box below. <br />
