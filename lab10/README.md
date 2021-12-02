# Pre-Lab Submission 10

## Step 1: Design a 1 Hz clock divider (clock_1hz) [10 points]

Using the hz100 clock, running at 100 Hz, and the reset signal, create a module that takes these inputs, and gives a hz1 output. The resulting module should, when it has its output connected to green, flash the green LED only once per second. You should recall how to do this from Lab 9, specifically the toggling clock that turns on the LED for one half of a second, then turns it off for the other half. You should not instantiate the count8du module within this module - rather, you should reuse the counter logic from that module to implement a counter within this module, and then use that to help generate the hz1 clock. <br />

Instantiate your module in the top module as: <br />
```
logic hz1;
clock_1hz cldiv (.hz100(hz100), .reset(reset), .hz1(hz1));
assign green = hz1;
```
So that we can evaluate the operation of the module you wrote, include the top module with the proper instantiation in your submission.

## Step 2: Design an encoder with synchronizer (scankey) [10 points]

This module will take the hz100 clock, reset, and inputs in[19:0] to generate a five-bit binary code (out) and a strobe output. The strobe output should be delayed by a two-flip-flop synchronizer. (See lecture notes for module 3-H for details about the synchronizer.) The strobe output will be used as a clock to any flip-flops that use the inputs as data inputs. If you recall, a flip-flop cannot have its clock be the same as its data signal. What the scankey module does is give you a more reliable data input by converting it into an all-encompassing 'keycode', which will be held high for at least a clock cycle before the strobe output goes high, making the strobe a reliable clock since the data input will satisfy the setup time requirement. <br />

You should build this module as a basic 32-to-5 encoder with strobe. (See lecture module 2-h page 9 for information about the basic encoder.) The outputs should be determined as follows: <br />
```
out[0] = in[1] | in[3] | in[5] | in[7] | ...
out[1] = in[2] | in[3] | in[6] | in[7] | ...
out[2] = in[4] | in[5] | in[6] | in[7] | ...
...
```
In this case, the most significant 12 inputs are unused, so there will never be more than 10 terms ORed together. If two inputs are active simultaneously, out will be the Boolean sum of the two input encodings. That Boolean sum is not a problem because the strobe output will be the result of an OR of any buttons pressed. Only the first key will cause a rising edge for the strobe output. Pressing multiple keys will change the out output, but since strobe is already high. <br />
Clear out the top module of the code you wrote for the previous step, but do not remove the previous module(s)! Then, instantiate this module in top as follows: <br />
```
logic strobe;
logic [4:0] keycode;
scankey sk1 (.clk(hz100), .rst(reset), .in(pb[19:0]), .strobe(strobe), .out(keycode));
assign right[0] = strobe;
assign right[5:1] = keycode;
```
Upon configuration of the FPGA/start of the simulation on the web simulator, you should see the right LEDs remain off until you press a button. The strobe light at right[0] should turn on (as it should for any button press), along with the corresponding LEDs for the binary value of the pressed button on right[5:1]. For example, pressing F should indicate the value 5'b01111 on right[5:1], and right[0] should be on. W will indicate 5'b10000 (since you are pressing 16, whose binary value is 5'b10000) and X will indicate 5'b10001 (since 17 is 5'b10001). W and X are important later because you will use X as a backspace key (to remove values from your password entry module for the digital combinational lock later) and W as a submit key (to save/submit your password after you've typed it in). You should try pressing each button in sequence to verify that it generates the binary correct code. If you press W and 4 simultaneously, you should see the value 5'b10100 on right[5:1], and that's the only way to see this value. You won't really be able to press them simultaneously, so a single strobe will generated for either the value 5'b10000 or 5'b00100. <br />
So that we can evaluate the operation of the module you wrote, include the top module with the proper instantiation in your submission. Do not forget to include the module that you wrote for this step. <br />

This is an extremely important module that you will use in every lab after this one, so you must take extra care to get it right. <br />



## Step 3: Design a number entry module (numentry) [10 points]

The numentry module takes the strobe output from scankey as a clock, named clk, as well as the 5-bit keycode as in[4:0], and the usual reset signal (reset) of the top module. In addition to the asynchronous reset signal, there is also a synchronous one named clr. The output is a 32-bit shift register called out. <br />

There should be two parts to this module - an always_ff for the main counter operation, and an always_comb to determine the next state for the counter. In the always_ff, asynchronously reset out to 32'b0 when reset is high, synchronously reset out to 32'b0 when clr is high, otherwise set out to the value of next_out, a 32-bit bus, but only when en is high. <br />

The always_comb must set next_out based on the following conditions: <br />

- If in is less than or equal to 9, do the following: (try to do this without actually saying in <= 9, using primitive logic gates instead.)
  - If out is zero, set next_out to be the lowest four bits of in.
  - Otherwise, set next_out to out shifted left by 4 bits ORed with the lowest four bits of in.
- Otherwise, just set next_out to out.

Instantiate the module in the top module as:
```
logic [31:0] entry;
logic [4:0] keycode;
logic btnclk;
scankey sk1 (.clk(hz100), .rst(reset), .in(pb[19:0]), .strobe(btnclk), .out(keycode));
numentry ne (.clk(btnclk), .rst(reset), .en(1'b1), .in(keycode), .out(entry), .clr(pb[17]));
display_32_bit d32b (.in(entry), .out({ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0}));  
```

**display_32_bit will need your ssdec module, so make sure to paste that in as well before you simulate.**

display_32_bit is a module that takes the 32-bit, 8-hex-digit, number that you generate from numentry, converts each of the digits to their respective seven segment form. You can make this module available on the simulator by ticking the box for "display32.sv" in Workspace Settings for the workspace you're working in (accessible via the gear icon next to the workspace name).  <br />

Check that your module works by first resetting the module with 3-0-W, which should turn off all the ssX displays except for ss0, which should display 0. Try pressing any of the decimal number pushbuttons (i.e. 0-9) and observe the number shift into the display, replacing the zero. Press a second button, and the first number should shift onto ss1, with the new number moving into ss0. Hopefully, this reminds you of how a calculator entry pad should work. Keep specifying numbers until you fill up the display, and press one more to see the number on ss7 disappear as the one on ss6 replaces it, the one on ss5 replaces ss6, and so on. You should not be able to press buttons A-F and have them by registered by numentry - only decimal numbers are allowed to maintain simplicity for the game you will play eventually. Try pressing pb[17] when the display is filled up to clear it, as well as reset. <br />
So that we can evaluate the operation of the module you wrote, include the top module with the proper instantiation in your submission. Do not forget to include the module that you wrote for this step. <br />



## Step 4: Design an extremely simple FSM (simonctl) [10 points]

This FSM module will be used as a "controller" for the Simon game that you will try in the lab. A video showing how the game works is available in the lab document, along with an explanation of how it works. You may benefit by reading and understanding the game operation before tackling a module that would function as its controller. <br />

The state provided by this module is how we inform the rest of the game what to do. There are two states - RDY (ready mode) and ENT (entry mode). <br />

- In RDY, Simon will show you the phrase "READY? X" where X is the current level. At this point, it is waiting for you to indicate readiness by pressing any button (this is akin to "Press any key to continue...").
- In ENT, a modified version of your count8du module from the previous lab will count down from a specified delay as the game shows you the number you must remember. Once the counter hits zero, the game will show you a number entry mode that starts with "0". At this point, you can now enter a number. The game will only compare numbers when you enter the same number of digits as you saw.

Given that you are implementing a state machine, it is only appropriate to show you a diagram for the [FSM](fsm.png)


You will implement this module, thus, as follows:

- First, place the following enum declaration into your module:
`typedef enum logic { RDY, ENT } simonstate_t;`
  This defines the states RDY and ENT for us as 0 and 1.
- In an always_ff block, set up the necessary logic to asynchronously reset state to RDY when a rising edge rst occurs, otherwise to set state to a new logic signal named next_state.
- Implement the logic for next_state as laid out in the FSM diagram. For the default case, when neither condition for going from RDY to ENT or vice versa is true, set next_state to state.

Clear out the top module of the code you wrote for the previous step, but do not remove the previous module(s)! Then, instantiate this module in top as follows:
```
logic state;
simonctl sctl (.clk(pb[0]), .rst(reset), .lvlmax(pb[16]), .win(pb[17]), .lose(pb[18]), .state(state));
assign right[0] = state;
```
To test your Simon controller, try the following:

- Press 3-0-W to reset the state machine to RDY. right[0] should be off.
- Without pressing any other buttons, press pb[0] once to advance the state machine to ENT, which will turn on right[0]. This is equivalent to pressing a button when "READY? X" appears.
- Press pb[0] again - this should change nothing. This behavior is required to prevent the state from changing when numbers are being entered.
- Now, hold down pb[18] to indicate that a wrong number was entered, and clock the state machine by pressing pb[0] again. right[0] should turn off as it returns to RDY. This is because upon entering a wrong number, the player needs to try again, so we ensure they're ready by returning to RDY.
- Clock the state machine one more time to reach ENT so that right[0] turns on, and this time, hold down pb[17] to indicate a correct number was entered. Clocking one more time should turn off right[0], since we would advance levels, and therefore show "READY? X" again, requiring us to return to RDY.
- Finally, clock to go to state ENT, with right[0] turning on, and hold down pb[16] and pb[17] while clocking one more time. Observe that this time, right[0] does not turn off, because we have indicated that we got the number right (win), at the last level of the game (lvlmax). At this stage, we're done with the game, which will perpetually show "GOODJOB!" to indicate the appreciation for the effort you have put in. Press 3-0-W one more time to return to RDY.

So that we can evaluate the operation of the module you wrote, include the top module with the proper instantiation in your submission. Do not forget to include the module that you wrote for this step.
