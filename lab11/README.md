# Pre-Lab Submission 11
## Step 1: An experiment [10 points]

Many students have a difficult time understanding the need for a delay synchronizer, so here is a simple exercise you can try.

We had great success in the previous lab with using a clock divider to take the 100 Hz clock, and step it down to rates like 1 Hz or 4 Hz to make a new clock that is used for the main digital system. Suppose we now want to construct a system that uses the push buttons to create the clock for our system. Consider the following diagram consisting of modules you are familiar with: <br />
[picture for no delay](nodelay.png) <br />
We want to use the strobe output of the enc16to4 module instance to directly clock a shift register like we've used before. The input data for the shift register will be the 7-bit decoded output of the seven-segment decoder. This way, every time we press a button, it will appear on the right side of the display and any previous digits will shift to the left. Brilliant!

It is easy enough to implement in the standard top module with the following statements:
```
  logic [63:0] scroll;
  assign {ss7,ss6,ss5,ss4,ss3,ss2,ss1,ss0} = scroll; // See note #1
  logic clk;
  logic [3:0] key;
  logic [6:0] ss;
  enc16to4 enc(.in(pb[15:0]), .out(key), .strobe(clk)); // See note #2
  ssdec ssd(.in(key), .out(ss), .enable(1'b1)); // See note #2
  always_ff @(posedge clk, posedge reset)
    if (reset)
      scroll <= 0;
    else
      scroll <= {scroll[55:0], 1'b0, ss};
```
First, a couple of implementation notes about the green text above:
1. Notice the order of the "assign" statement that connects the scroll bus to the seven-segment displays. It must be in this order to work well in all simulators. If you turn it around, it still works in the Verilog FPGA simulator, and it would work fine if we were synthesizing the design into an actual FPGA, but it doesn't necessarily work with the simulators we use to grade your assignment submissions. There is a definite direction that data is moving in this "assign". Always make sure that the source is on the right and the destination is on the left, as we've shown here.
2. When creating instances enc16to4 and ssdec, all the port connects are made name-based rather than order-based. We didn't tell you what order to arrange the ports of your modules, and you don't know the order of the ports in the modules we use to grade your work. Always use name-based port connection when you create instances of modules that you are not submitting.
Back to the original topic... <br />

#### **Try it**

Once you've implemented this design in the simulator, try it. The first button you should press is '0', and it works great! The second button you should press is '1', and ... you get another zero??? The third button you should press is '2', and ... still zero. Actually, every one of the buttons from '0' to 'F' puts a new zero into the display. <br />

Why? <br />

The enc16to4 module is combinational. When one of the inputs changes, the out and strobe outputs change quickly afterward. There may be slightly more delay for the one or the other. It depends on how you implemented your enc16to4 module. The strobe is wired directly to the clock of the always_ff block that updates the scroll bus. The out bus of the enc16to4 module is connected to an instance of the ssdec module. It definitely takes more time for data to get from the encoder's out, through the ssdec instance, to the always_ff block. That means that, by the time the new data reaches the shift register, the strobe already clocked the shift register. <br />

This doesn't work. <br />


#### **Add a delay**

We could make this work if we could add a delay between the strobe output of the encoder and the clock of the always_ff block. There is no such thing as a "delay" gate, so we'll have to construct a way to make a long enough delay that the clock is guaranteed to arrive after the ss[6:0] signal is stable is set to the pattern corresponding to the button pressed.

The way we do this is as follows: <br />
[picture for delay](delay.png)

The only difference in this revised diagram is that there are two flip-flops—both clocked by hz100—between the strobe output and the clock of the always_ff block. Both flip-flops are cleared to zero by the reset signal.

There are two reasons why we need more than a single flip-flop to produce a reliable delay. Both are due to the fact that the hz100 signal is not synchronized with button presses, and this leads to some non-deterministic possibilities:
- With only one flip-flop, there is a small chance that the strobe output will go high just before the hz100 clock goes high—possibly so close that it is output on the flip-flop's q output before the key has propagated through the ssdec instance... which means, effectively, there is no strobe delay. Having two flip-flops means that there will be at least one hz100 period between strobe going high and the clk line being driven high. Surely 1/100th of a second is enough of a delay.
- There is a small chance that strobe will go high so close before the rising edge of hz100 that it will result in a setup violation for the flip-flop. This means that the flip-flop output will be metastable and oscillate. We want to use that output as the clock input for the scroll shift register, so oscillation would be a very bad thing. (If you could try this on real FPGA hardware, you'd see how colossally bad it is. You don't get the effect with just a simulator.) Having two flip-flops means that the oscillation of the first flip-flop will most assuredly subside by the next hz100 clock.
This system is called a two-flip-flop synchronizer and it is useful for more than just delaying buttons. Anytime there is a need to share a signal between two unsynchronized domains, a two-flip-flop synchronizer must be used.
#### **Implementing the delay**

Add the two-flip-flop delay between the strobe output and the always_ff block. Get the satisfaction of seeing the system work as it was intended. You should be able to press any of the '0' through 'F' buttons and have it appear on the right digit of the display. Test your system well. Make certain that you have exactly two flip-flops between strobe and the always_ff block that updates the scroll shift register. Also make certain that the reset signal clears both flip-flops to zero. The two-flip-flop synchronizer is, effectively, a two-bit shift-register with an asynchronous clear. (See lecture module 3-H for more details and examples for synchronizers.)


**Hint:** Are you having trouble with the concept of a two-flip-flop synchronizer? Think back to the concept of a ring counter. Can you build an 8-bit ring counter, initialize it to 8'b00000001, clock it with hz100, and connect it to right[7:0] to visualize it? Sure you can. <br />
Now, reduce that to a two-bit shift register. Clock it with hz100, but don't reset it. Don't connect it to right[7:0] either. Instead of setting the next state of bit 0 to the most significant bit, set it to the strobe output of the enc16to4 instance. Finally, use bit 1 of the shift register as the signal that you use to clock the always_ff that updates the scroll bus. That's a two-flip-flop synchronizer.



When you have completed it, copy and paste only the top module into the text box below.

## Step 2: Design a special register [10 points]

Now that you have a reliable means of key entry, design a system that looks like this:
[picture for digits system](digits.png) <br />

The **digits** module should do the following things:

- **reset** is an asynchronous reset. As long as it is asserted, the out bus will be 32'b0.
- **clk** tells the module to look at the five-bit in bus, and do something with it.
- **in** is a five-bit bus that causes the following things to happen to the out bus for the following values:
  - **5'b00000 - 5'b01111:** Shift the value of out left by four bits, and set the lower four bits of out to the lower four bits of in. This is just implementing the shift mechanism as you've seen before.
  - **5'b10000:** Clear the value of out to zero.
  - **5'b10001:** Erase the last-entered digit of out by shifting it right by four bits and setting the most significant four bits to zero.
  - **5'b10010:** Add one to the 32-bit value of out. You may use the '+' operator for this. Go ahead. It's easy:
	`out <= out + 1;`
  - **5'b10011:** Subtract one from the 32-bit value of out. You may use the '-' operator for this. It's also easy:
	`out <= out - 1;`
  All of these operations can be implemented by creating next-state logic for the system, and then assigning that to out on the rising edge of clk, or create nested "if"s or a "case" statement in the always_ff block that implements the state update for out. Using the '+' and '-' operators makes things easy for the sake of creating this sequential system. We'll study the mechanics of arithmetic in detail in the next homework and next lab. <br />

**Hint:** The out bus is just a register whose next state is determined by the value of in on the next clock. The easiest way to implement the next-state logic is with a casez block. The digits '0' - 'F' are represented with the wildcard 5'b0????.


Put the following statements into the **top** module to test the **digits** module:
```
  logic [4:0] keycode;
  logic strobe;
  scankey sk1 (.clk(hz100), .rst(reset), .in(pb[19:0]), .strobe(strobe), .out(keycode));
  logic [31:0] data;
  digits d1 (.in(keycode), .out(data), .clk(strobe), .reset(reset));
  ssdec s0(.in(data[3:0]),   .out(ss0[6:0]), .enable(1'b1));
  ssdec s1(.in(data[7:4]),   .out(ss1[6:0]), .enable(1'b1));
  ssdec s2(.in(data[11:8]),  .out(ss2[6:0]), .enable(1'b1));
  ssdec s3(.in(data[15:12]), .out(ss3[6:0]), .enable(1'b1));
  ssdec s4(.in(data[19:16]), .out(ss4[6:0]), .enable(1'b1));
  ssdec s5(.in(data[23:20]), .out(ss5[6:0]), .enable(1'b1));
  ssdec s6(.in(data[27:24]), .out(ss6[6:0]), .enable(1'b1));
  ssdec s7(.in(data[31:28]), .out(ss7[6:0]), .enable(1'b1));
```

When the system is started (or reset), the display should show eight zeros on the seven-segment LEDs. When a number button is pressed, the new digit should appear on right display. Each new digit will slide the original digits to the left. <br />

When the 'W' button is pressed, it should clear all the digits to zero. <br />

When the 'X' button is pressed, it erase the digit on the right by sliding all of the digits to the right. <br />

When the 'Y' button is pressed, the entire 8-digit, 32-bit hexadecimal value should be incremented by one. Try entering the value FFFFFFFF and pressing the 'Y' button. It should show 00000000. <br />

When the 'Z' button is pressed, the entire 8-digit, 32-bit hexadecimal value should be decremented by one. Try entering the value 00000000 and pressing the 'Z' button. It should show FFFFFFFF. <br />

When your system works, copy and paste only the digits module into the text box below. <br />

## Step 3: Don't show the leading zeros [10 points]

Change the statements provided for the top module to test the digits module in step 3. Modify them so that if a four-bit chunk of the data is zero, and all of the higher-significant four-bit chunks is also zero, do not display the digit. Do this by turning off the enable input of the appropriate ssdec. <br />

You should always leave the least-significant display (ss0) enabled at all times. This way, if the value of data is 00000000 (hexadecimal), then it will show only 0. The first time a digit is entered, that single zero will be replaced by the new value. <br />

**Hint:** It is not necessary to create lots of logical expressions to implement this. Use a Verilog reduction operator. (See lecture module 3-E, page 18) For instance, the ss7 digit should be enabled if any of the data[31:28] bits are 1. What is a succinct way of saying data[31] | data[30] | data[29] | data[28] ? Use the reduction operator for OR.
Similarly, ss6 is enabled for any 1 bits in data[31:24], ss5 is enabled for any 1 bits in data[31:20], and so on.


When you are finished, copy and paste only the top module into the text box below. <br />

And now you have something that looks like a calculator display. That's enough preparation for the lab experiment. And now you have something that looks like a calculator display. That's enough preparation for the lab experiment.
