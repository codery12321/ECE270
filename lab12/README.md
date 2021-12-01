# Pre-Lab Submission 12

## Step 1: A half-adder [2 points]
Construct a half-adder module. The module should be named ha. It should have two single-bit inputs named a and b. It should have two single-bit outputs named s (sum) and co (carry-out).  <br />

You can instantiate and test the half-adder module with the following: <br />
  `ha h1(.a(pb[0]), .b(pb[1]), .s(right[0]), .co(right[1]));`  <br />
Include this module in the text box at the bottom of the page. <br />

## Step (2): A full adder built from two half-adders [2 points]
Construct a full adder by instantiating two of the ha half-adder modules you designed for the previous step. You'll need to use an additional OR gate (use a dataflow OR expression) to create the carry-out of the full adder. <br />
The full adder module should be named faha. It should have three input ports named a, b, and ci (carry-in). It should have two output ports named s (sum) and co. <br />

You can instantiate and test the full-adder module with the following: <br />
  `faha f1(.a(pb[0]), .b(pb[1]), .ci(pb[2]), .s(right[0]), .co(right[1]));` <br />
 <br /> Make sure that it satisfies the following truth table: <br />
```
a   b   ci  co  s
0	0	0		0	0
0	0	1		0	1
0	1	0		0	1
0	1	1		1	0
1	0	0		0	1
1	0	1		1	0
1	1	0		1	0
1	1	1		1	1
```
Include this module in the text box at the bottom of the page.

## Step 3: A full adder built from scratch [2 points]
Construct a full adder by writing dataflow expressions for the outputs or by constructing a case statement for each combination of the inputs. Do not instantiate modules you designed for the previous steps.  <br />
The full adder module should be named fa. It should have three input ports named a, b, and ci (carry-in). It should have two output ports named s (sum) and co.  <br />

You can instantiate and test the full-adder module with the following: <br />
  `fa f1(.a(pb[0]), .b(pb[1]), .ci(pb[2]), .s(right[0]), .co(right[1]));` <br />
Make sure that it satisfies the truth table shown in the previous question.   <br />

Include this module in the text box at the bottom of the page.  <br />
## Step 4: A four-bit full adder [4 points]
Construct a four-bit full adder by creating four instances of the fa module you made in the previous step.  <br />
This four-bit full adder module should be named fa4. Inside of this module, you should create four instances of the fa module with the carry-out of each one connected to the carry-in of the next most significant adder. It should have two four-bit input ports named a and b, and a single-bit input named ci (carry-in). It should have a four-bit output port named s (sum) and a single bit output port named co (carry-out). <br />

You can instantiate and test the full-adder module with the following: <br />
  `fa4 f1(.a(pb[3:0]), .b(pb[7:4]), .ci(pb[19]), .s(right[3:0]), .co(right[4]));` <br />
so that the '3'...'0' buttons represent a four-bit input operand, the '7'...'4' buttons represent the second four-bit input operand, and the 'Z' button is the carry-in. The right[3:0] show the sum, and the right[4] shows the carry-out.  <br />

Try testcases such as the following: <br />
```
a	    b	    ci co	s
0000	0000	1		0	0001
1111	0001	0		1	0000
1111	1111	0		1	1110
1111	1111	1		1	1111

```
Include this module in the text box at the bottom of the page.

## Step 5: An eight-bit carry look-ahead adder [5 points]
Construct an eight-bit carry look-ahead adder by eight instances of the ha module you made in step 1. Yes, this is the hard way to do this, but take your time and make it work.
This eight-bit carry look-ahead adder module should be named cla8. It should have two eight-bit input ports named a and b, and a single-bit input named ci (carry-in). It should have an eight-bit output port named s (sum) and a single bit output port named co (carry-out).

You can instantiate and test the adder module with the following: <br />
`  cla8 cl1(.a(pb[7:0]), .b(pb[15:8]), .ci(pb[19]), .s(right[7:0]), .co(red));` <br />
so that the '7'...'0' buttons represent a eight-bit input operand, the 'F'...'8' buttons represent the second eight-bit input operand, and the 'Z' button is the carry-in. The right[7:0] show the sum, and the center red LED shows the carry-out.  <br />

We'll let you come up with your own testcases, but test it well and include this module in the text box at the bottom of the page.  <br />

## Step 6: An eight-bit adder/subtracter [5 points]
Construct an eight-bit adder/subtracter that instantiates the cla8 adder you constructed in the previous step. <br />
This module should be named addsub8. It should have two eight-bit input ports named a and b, and a single-bit input named op to specify whether the operation is (0) addition of A+B or (1) subtraction of A-B. It should have an eight-bit output port named s (sum) and a single bit output port named co (carry-out). <br />

You can instantiate and test this module with the following:
  `addsub8 as1(.a(pb[7:0]), .b(pb[15:8]), .op(pb[18]), .s(right[7:0]), .co(red));` <br />
so that the '7'...'0' buttons represent a eight-bit input operand, the 'F'...'8' buttons represent the second eight-bit input operand, and the 'Y' button specifies the operation. The right[7:0] show the sum, and the center red LED shows the carry-out.  <br />

Here are some example testcases: <br />
```
a	          b	      op	co	s
00000000	00000000	1		1	00000000
00000000	00000001	1		0	11111111
00000000	00000011	1		0	11111101
00000111	00000111	1		1	00000000
```
Include this module in the text box at the bottom of the page.  <br />

## Step 7: A single-digit BCD adder [5 points]
Construct a single-digit (4-bit) BCD adder. This is just a four-bit binary adder with the correction circuit described in lecture module 4-D. <br />
This module should be named bcdadd1. Inside this module, create an instance of the fa4 adder you constructed in a previous step. The module should have two four-bit input ports named a and b, and a single-bit input named ci (carry-in). It should have a four-bit output port named s (sum) and a single bit output port named co (carry-out). <br />

You can instantiate and test this module with the following: <br />
```
  logic co;
  logic [3:0] s;
  bcdadd1 ba1(.a(pb[3:0]), .b(pb[7:4]), .ci(pb[19]), .co(co), .s(s));
  ssdec s0(.in(s), .out(ss0[6:0]), .enable(1));
  ssdec s1(.in({3'b0,co}), .out(ss1[6:0]), .enable(1));
  ssdec s5(.in(pb[7:4]), .out(ss5[6:0]), .enable(1));
  ssdec s7(.in(pb[3:0]), .out(ss7[6:0]), .enable(1));
```
so that the '3'...'0' buttons represent a four-bit input operand, the '7'...'4' buttons represent the second four-bit input operand, and the 'Z' button specifies the carry-in. The ss7 and ss5 displays will show the input operands, and the ss1/ss0 combination will show the two-digit decimal sum.  <br />

Test it thoroughly to make sure it always indicates the decimal sum. Include this module in the text box at the bottom of the page.  <br />

## Step 8: A four-digit BCD adder [10 points]
Construct an four-digit (16-bit) BCD adder. <br />
This module should be named bcdadd4. Inside this module, create four instances of the bcdadd1 adder you constructed in the previous step. Chain the carry-out of each one to the carry-in of the next more significant single-digit BCD adder. The module should have two 16-bit input ports named a and b, and a single-bit input named ci (carry-in). It should have a 16-bit output port named s (sum) and a single bit output port named co (carry-out).  <br />

It's rather difficult to test something like this by pressing buttons. Instead, create successive iterations of static values in the top module instantiation. For instance, you can instantiate and test this module with the following: <br />
```
  logic co;
  logic [15:0] s;
  bcdadd4 ba1(.a(16'h1234), .b(16'h1111), .ci(0), .co(red), .s(s));
  ssdec s0(.in(s[3:0]),   .out(ss0[6:0]), .enable(1));
  ssdec s1(.in(s[7:4]),   .out(ss1[6:0]), .enable(1));
  ssdec s2(.in(s[11:8]),  .out(ss2[6:0]), .enable(1));
  ssdec s3(.in(s[15:12]), .out(ss3[6:0]), .enable(1));
```
You should see the result 2345 on the seven-segment displays. If you change the inputs to 16'h9876 and 16'h3333, the output should show 3209, and the red LED will be illuminated to indicate carry-out. Be sure to try cases with the ci input port set to 1.  <br />

Test it thoroughly to make sure it always indicates the decimal sum. Include this module in the text box at the bottom of the page.  <br />

## Step 9: A nine's-complement circuit [5 points]
Construct a BCD nine's-complement circuit. This is a simple combinational module that accepts a four-bit BCD digit, x, and outputs the digit the value 9-x. You can implement it as a case statement.
This module should be named bcd9comp1. It has one four-bit input in and one four-bit output out.  <br />

You can instantiate and test this module with the following: <br />
```
  logic [3:0] out;
  bcd9comp1 cmp1(.in(pb[3:0]), .out(out));
  ssdec s0(.in(pb[3:0]), .out(ss0[6:0]), .enable(1));
  ssdec s1(.in(out),     .out(ss1[6:0]), .enable(1));
```
pb[3:0] accept a four-bit BCD digit that will be displayed on ss0. The nine's complement should be displayed on ss1. The sum of the digits displayed on ss0 and ss1 should always be 9. It does not matter what is displayed if the input value is greater than 9 (larger than a BCD number).  <br />

Test it thoroughly, and include this module in the text box at the bottom of the page.  <br />
## Step 10: A four-digit ten's-complement adder/subtracter [10 points]
Construct an four-digit BCD ten's-complement adder/subtracter module. This is analogous to how you created the 4-bit binary adder/subtracter. With that module, you computed the one's-complement of the second operand to the adder and then added one to it by setting the carry-in of the adder. This was effectively equivalent to adding the two's-complement inverse to perform a subtraction.  <br />

In this case, you're going to compute the nine's-complement of each BCD digit (using the bcd9comp1 module you just made), and selectively use that as the input to a four-digit BCD adder (bcdadd4) that you constructed earlier. When you carry one into the bcdadd4, you effectively add the ten's-complement inverse to perform a subtraction.  <br />

Of course, the result will be a ten's-complement negative number, which will look very strange. We'll do a better job of displaying that in the lab. <br />
This module should be named bcdaddsub4. It has two 16-bit inputs a and b. It has another one-bit input named op that indicates (0) addition of A+B or (1) subtraction of A-B. It has a 16-bit output named s (sum). There's no need to have a carry-out for this module.  <br />

Once again, it's difficult to test this by pressing buttons. Instead, you can repeatedly instantiate and test this module with static operands: <br />
```
  logic [15:0] s;
  bcdaddsub4 bas4(.a(16'h0000), .b(16'h0001), .op(1), .s(s));
  ssdec s0(.in(s[3:0]),   .out(ss0[6:0]), .enable(1));
  ssdec s1(.in(s[7:4]),   .out(ss1[6:0]), .enable(1));
  ssdec s2(.in(s[11:8]),  .out(ss2[6:0]), .enable(1));
  ssdec s3(.in(s[15:12]), .out(ss3[6:0]), .enable(1));
```
For this example, the 7-segment displays should show 9999, which is the ten's complement way of saying -1.  <br />

Test it thoroughly, and include this module in the text box at the bottom of the page.

You might also try incorporating some of these constructs into the calculator you built for lab 11. That's what we did in previous semesters for lab 12.


# ECE 270 Lab Experiment 12: Adders and the Lunar Lander

This lab, and the next one, may be a bit of a time crunch, which is why we've tried to release it a bit earlier than usual. The time crunch is intended to get you used to the upcoming lab practical, where you will implement a specified Verilog design from scratch on the lab machines, with no access to course material, all within two hours. The implementation in this lab is very detailed, but it may not be the case for the lab practical.
If you have been struggling with Verilog thus far, it would be a good idea to start early using the simulator. Make use of the time before your lab to understand the concepts you're implementing, and try to implement them without using code from the notes. We've tried to make the lab instructions applicable to both in-lab implementation and simulator implementation.
Keep in mind that you still need to go to lab to get the entire design checked off by a TA on the lab FPGA.

## Introduction

You have been tasked with the great responsibility of writing an arithmetic unit for a lander headed for the Moon! We will have you implement adder/subtractor modules in order to realize an arithmetic logic unit for this lander. This unit, unlike the regular one that's in most CPUs, will be used to calculate the altitude, vertical velocity, and fuel of such a lander probe. <br />

For the context of this experiment, we will make the following simplifying assumptions: <br />

- The lander starts at some height over the Moon, and the gravity of the Moon, at 5 ft/s2, will cause the lander to start falling towards the ground.
- The force of gravity is counteracted by the lander's thrust setting, which can be set anywhere between 0 to 9 ft/s2. As a result, you could turn off the thrusters to free fall towards the Moon (0 ft/s2), or engage them at highest thrust (9 ft/s2).
- Your lander will either crash or land. It will crash if the downward lander velocity is larger than 30 ft/s or the thrust is higher than 5 - otherwise, it will land.

## Step 0: Prelab

- Read the notes for module 4-A to 4-D.
- Read the entire lab document.
- Do the prelab assignment on the course web page.
>If you cannot implement the full lab by the end of your lab section, you may still receive partial credit by showing the code you've written to your TA. Credit will be awarded based on how much functionality was implemented versus what was expected.

## Step 1: Implementing the Lunar Lander

Run the ece270-setup script to get the necessary files. **Make sure to run this command for every day that you're working in the lab in order to get patches that may be issued to the Verilog make build system.**

If you're on the simulator, copy the provided top.sv file into a new workspace, and enable File Simulation. You'll do most of your work in the lunarlander module, so start there!

The substeps below cannot be tested individually since the entire design is tightly integrated. As a result, you'll need to actually finish all the substeps before simulating. Take extra care to follow the instructions, and try to look ahead to potential problems as you're following them - it could be that you have to define extra signals or buses not mentioned in the instructions. These unexpected situations may arise as you're writing code during a lab practical, and you should know how to fix them when they occur.

## 1.1 Use your bcdaddsub4 module to calculate landing parameters

You will implement the following equations using your bcdaddsub4 module from the prelab.
```
alt* = alt + vel
vel* = vel - gravity + thrust
fuel* = fuel - thrust
```
quantity* is meant to imply that this is the next-state register for the corresponding quantity, eg. fuel* is the next value of fuel that will be set in fuel on the next rising edge of the clock. Keep in mind that you cannot use asterisks as signal/bus names, so you'll need to give these proper names in code! <br />

Make sure to first review the top.sv file to understand the layout of the code that you'll be writing. Then, in the lunarlander module, create eight buses - each one 16 bits long - for alt, vel, fuel and thrust, to store the current values, and newalt, newvel, newfuel and manualthrust, the first three of which will store the result of bcdaddsub4 modules to calculate the new altitude, velocity and fuel, and the fourth to store the value that you may input using the pushbuttons to change the thrust from 0 to 9. <br />

Next, insert the bcdaddsub4 module from your prelab (and any other relevant modules you may need), and make four instantiations within the corresponding section of the lunarlander module, with the connections as follows: <br />

- For the first instantiation, you will determine the new value of altitude based on the equation. Therefore the a input will be your current altitude, the b input will be your current velocity, op will be 1'b0, and the s output will be the new altitude.
- For the second and third instantiations, you will determine the new velocity based on the equation. Use two instantiations to break down the new velocity equation such that you calculate vel - GRAVITY with the first instance, connect its sum to a new intermediate 16-bit bus (call it intval), and in the second instance, perform the calculation intval + thrust and connect the sum to the new velocity bus. Keep in mind that op should be 1'b1 for subtractions.
- For the fourth instantiation, calculate the new fuel by setting up the ports such that the instance does newfuel = fuel - thrust.

## 1.2 Set up a modifiable thrust register

For this part, you'll need the **scankey** module from a previous lab. <br />

In the comment section marked 1.2, create a clocked register in an always_ff block that sets manualthrust to the value of the currently pressed button, but only if the button pressed is 0-9 (you should understand how to use the scankey module to do this, given that in is the pushbutton input, and you should produce a 5-bit out and delayed strobe). Use hz100 and rst as the clock and async reset for scankey, and for the always_ff setting manualthrust, set the scankey's strobe as the clock, and the usual rst as the async reset. If rst is asserted, set manualthrust to the constant THRUST. <br />

The behavior should be such that when you press a button 0-9, the corresponding binary value should be stored into manualthrust. Note that manualthrust is a 16-bit register, so you may need to pad the 4-bit scankey output with zeroes. (We say 4-bit since there is no use for the fifth bit of the scankey output, out[4], since we will only use buttons 0-9 for setting the thrust in this step.) <br />

## 1.3 Set up the state machine logic for the lander

We've now come to the bulk of the code - the state machine that will be used for the lander. Create an enum datatype to define the states of this machine as follows: <br />
```
      typedef enum logic [2:0] {INIT=0, CALC=1, SET=2, CHK=3, HLT=4} flight_t;
      logic [2:0] flight;
      logic nland, ncrash;
```    
Set up an always_ff block with clk and rst as clock and asynchronous reset, and have it do the following:  <br />

- If rst is high:
  - Initialize flight to INIT.
  - Initialize the crash and land outputs, and their next-state signals ncrash and nland, to 0.
  - Initialize fuel, alt, vel, thrust to the constants FUEL, ALTITUDE, VELOCITY and THRUST. Note that these constants are the same ones in the parameter section of the lunarlander module.
- Otherwise (the easiest way to write the following is a case statement within the same always_ff block):
  - If flight is INIT:
    - Simply set flight to CALC! (We just started the state machine, so we'll start by immediately calculating the new values of altitude, velocity and fuel based on the current values, and the provided thrust.)
  - Otherwise if flight is CALC:
    - Simply set flight to SET! (Nothing happens in terms of the state machine, but that's because the calculation is happening in the bcdaddsub4 module instances, so we add a CALC stage to give it time to calculate the new values).
  - Otherwise if flight is SET:
    - If the new value of fuel is negative (i.e. if newfuel[15] is 1) set fuel to 0, otherwise set it to newfuel. (We can't have negative fuel!)
    - Set alt to newalt.
    - Set vel to newvel.
    - If the new value of fuel is negative or if fuel is currently zero, set thrust to 0, otherwise set it to manualthrust. (This ensures we don't have a lander that can magically fly up with zero fuel, and we can't manually change thrust to anything from zero if fuel is zero.)
    - Set flight to CHK.
  - Otherwise if flight is CHK:
    - If the new value of altitude is negative (i.e. if newalt[15] is 1), thrust is less than or equal to 5, and newvel is larger than 16'h9970, set nland to 1 and flight to HLT. (We tried to land too fast, and ended up crashing, and so we must halt (HLT)!)
    - Otherwise if the new value of altitude is negative (i.e. if newalt[15] is 1), set ncrash to 1 and flight to HLT. (We landed at a safe speed and thrust, so it was a safe landing, and so we must halt (HLT)!)
    - Otherwise, set flight to CALC.
  - Otherwise if flight is HLT: (then we either landed or crashed)
    - Set the value of land to nland.
    - Set the value of crash to ncrash.
    - Set the value of alt to 0. (We're on the ground...)
    - Set the value of vel to 0. (...and we're not going anywhere!)

## 1.4 Set up the display mechanics
For this portion, you'll need to copy over the display_32_bit and ssdec modules from lab 10. You'll now set up the part of the module that displays the altitude, velocity, fuel and thrust on the ssX displays. We'll give you the following code to place into the corresponding section:
```
      logic [23:0] lookupmsg [3:0];
      logic [1:0] sel;
      logic [15:0] val;
      always_comb begin
        lookupmsg[0] = 24'b011101110011100001111000;  // alt
        lookupmsg[1] = 24'b001111100111100100111000;  // vel
        lookupmsg[2] = 24'b011011110111011101101101;  // fuel (says gas)
        lookupmsg[3] = 24'b011110000111011001010000;  // thrust
      end
```    
This block sets up the ss7-ss5 displays to show "ALT", "VEL", "GAS" (for fuel) and "THR" (for thrust). You'll modify this block to add a case statement that checks the value of sel, and do the following: <br />

- If sel is 0, set val to alt.
- If sel is 1, set val to vel.
- If sel is 2, set val to fuel.
- If sel is 3, set val to thrust.

Notice that you should not need a default case! <br />

The lander's velocity should eventually become negative as the lander picks up speed falling towards the Moon's surface. If you may recall from Module 4, negative numbers aren't represented so easily in hardware. If you had to store the value "-30" in a 4-digit, 16-bit register, it would be represented in 4-digit, base-10, 2's-complement form as 9970 (each digit stored in BCD form). <br />

To ensure that we would show "-30" and not "9970", we will set up a new 16-bit bus called negval, which will store the value (0 - val). If val ends up being negative, then (0 - val) would give us the positive value, and we can simply prepend a minus sign in front of it while displaying it. <br />

Instantiate bcdaddsub4 one more time to perform this negation. Plug in 0 to the a input port, val to the b input port, and 1'b1 to the op input port. Connect the sum to negval. <br />

To do this, create two 64-bit buses called valdisp and negvaldisp and a new 16-bit bus called negval. Create two instances of display_32_bit - connect {16'b0, val} and {16'b0, negval} to the instance in ports, and valdisp and negvaldisp to the instance out ports. (Keep in mind that val and negval go to different instances!) <br />

Next, create a new always_comb block, and in it, assign ss accordingly: <br />

- If val is negative (val[15] is 1), connect ss to `{lookupmsg[sel], 8'b0, 8'b01000000, negvaldisp[23:0]}.` Note the inclusion of 8'b01000000 - this is your minus sign, on the G segment of ss3!
- Otherwise, connect ss to `{lookupmsg[sel], 8'b0, valdisp[31:0]}.` <br />

Finally, create an always_ff block clocked by scankey's strobe, and reset by rst. If rst is high, set sel to 0, otherwise:
- If scankey's output is 5'b10000 (W is pressed), set sel to 3. (Pressing W should display thrust.)
- If scankey's output is 5'b10001 (X is pressed), set sel to 2. (Pressing X should display fuel.)
- If scankey's output is 5'b10010 (Y is pressed), set sel to 1. (Pressing Y should display vel.)
- If scankey's output is 5'b10011 (Z is pressed), set sel to 0. (Pressing Z should display alt.)

## 1.5 Instantiate the Lunar Lander and set up a slower clock

We're nearing the end! <br />

The lunarlander module, if clocked at 100 Hz, will probably run too fast for you to properly read the altitude/velocity/fuel values as they update on every loop through the state machine. Thus, we actually allow for two clock ports in the module - one for the regular 100 Hz hz100 clock in the top module, and a clock divided from hz100 that the module will use to simulate the landing by cycling through the FSM. We use the slower clock to allow for easier viewing of lander parameters as they update, and use the hz100 clock for the scankey module so you can update the thrust. <br />

Note that when you actually run your design and try to change the thrust, it will only change upon the next rising edge of the slower clock, and not immediately - this is intentionally done to avoid setup time violations. <br />

Using knowledge from previous labs, implement a slower clock in the top module, and connect it to a new logic signal, hzX. The frequency is up to you - keep in mind that you don't want it too fast that you can't read the values as they update, and you don't want it too slow that you and your TA end up awkwardly watching the board waiting for the lander to land. We used 4 Hz. <br />

Then, instantiate the lunar lander module as follows: <br />
```
      lunarlander #(16'h800, 16'h4500, 16'h0, 16'h5) ll (
        .hz100(hz100), .clk(hzX), .rst(reset), .in(pb[19:0]), .crash(red), .land(green),
        .ss({ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0})
      );
```    
## Step 2: Flash and demonstrate your design on the FPGA

If you're directly using the instantiation above, your "lander" will do the following: <br />

- It will appear 4500 feet above the moon, so your altitude will show 4500.
- It will stay in the same exact spot, since thrust and gravity are set equal to each other at 5 ft/s2. Velocity was initialized to 0, so it'll stay that way until you change the thrust.
- It will consume fuel (or gas on the display) at the rate of 5 units/clock cycle. The fuel should not run out, otherwise you will no longer be able to turn on your lander's thrusters!
 <br />Try toggling the display selectors to show altitude/velocity/fuel/thrust using Z/Y/X/W respectively, and use them to try to land your shuttle as shown in the video. If your design works the same way as the video on the top of the page (not necessarily with the exact same values), great job! Attempt a crash as well, and show both scenarios to a TA to get checked off. Then, submit it in your postlab. <br />

Enjoy your Thanksgiving break!
