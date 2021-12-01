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
  - **5'b10010:** Add one to the 32-bit value of out. You may use the '+' operator for this. Go ahead. It's easy: <br />
	`out <= out + 1;` <br />
  - **5'b10011:** Subtract one from the 32-bit value of out. You may use the '-' operator for this. It's also easy: <br />
	`out <= out - 1;` <br />
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

And now you have something that looks like a calculator display. That's enough preparation for the lab experiment.

# ECE 270 Lab Experiment 11: Simple Hexadecimal Calculator <br />

## Introduction

Through the course so far, you have mostly dealt with the update of only one signal in an always_ff block. That signal may have been a bus—and, therefore, a group of signals—but you have thought of it as one group of data. Now it is time to consider the update of multiple data in the same always_ff block. We will do so in the context of starting to use arithmetic operations. Although the topic of recent lectures has been the implementation of arithmetic, we'll defer practicing that for future assignments. Instead, we'll use the built-in Verilog arithmetic operators (like '+', '-', '*', '/', and '%'). The important part of this lab will be to gain experience in construction of more complicated, composite, modular state machines. <br />

The goal of the lab is to build a simple hexadecimal calculator with a familiar user interface. For a hexadecimal calculator, you will extend the number entry system you built in the prelab which will accept multi-digit numbers. You will gradually modify it to improve the user interface. <br />

After entering a multi-digit number on the calculator, (and using 'X' as a backspace key), you can press a button to select an operation. The operations the calculator will initially support are as follows: <br />

- 'Y': Add the entered number to another number to be entered. <br />
- 'Z': Subtract the number entered next from the one already entered. <br />
- 'W': Complete the previously selected operation on the numbers entered. (This is analogous to the '=' button on a conventional calculator. <br />
In the end, you should be able to add two hexadecimal numbers with a sequence like: <br />
          B 2 B 5     Y     3 F 8 5     W <br />
        (16'hb2b5) (plus) (16'h3f85) (equals) <br />

and see the result, 16'hf23a, displayed. Similarly, if you enter a sequence to subtract one number from another: <br />
          F 2 3 A     Z     3 F 8 5      W <br />
        (16'hf23a) (minus) (16'hb2b5) (equals) <br />

you'll see the result, 16'hb2b5, displayed. <br />
## Step 0: Prelab <br />

- Study the notes for modules 4-A through 4-F to understand arithmetic operations like addition, subtraction, and multiplication.
- Read the entire lab document.
- Do the prelab assignment on the course web page.
## Before we begin: Debugging

You are implementing the functionality of this digital system design almost entirely inside a module that is instantiated into top. One of the biggest difficulties students have is in debugging a system like this. It is not possible to connect a signal inside the digits module to, say, the right[7:0] bus to see what it looks like. How can problems with this design be debugged? <br />

Ordinarily, simulation tools allow you to run a testbench to collect traces of signals that exist both at the periphery of the design (the inputs and outputs of the top-level module) as well as the internal signals of hierarchical instances. This is why instances of modules must have names. This allows you to refer to a data signal inside the 'd1' instance of the digits module in top as something like "top.d1.data". <br />

We don't quite have the luxury of that kind of debugging in our current simulator... Maybe someday. <br />

In the meantime, you can still add extra outputs to a module and connect them to LEDs in top. You should remove those extra outputs once you are done, but it should not affect the operation of the module if you turn it in as-is. <br />

For instance, if you wanted to look at an 8-bit value in an instance of the digits module, you could define it as: <br />
```
          module digits(input logic [4:0] in, input clk, reset,
                        output logic [31:0] out,
                        output logic [7:0] peek);
          endmodule
```
Then, in the instantiation in top, you could then say: <br />
```
          digits d1 (.in(keycode), .out(data), .clk(strobe), .reset(reset),
                     .peek(right));
```
Now you can connect any value you need to see to peek and see what it looks like on the right LEDs. <br />

It is important to understand that this is only possible because we use name-based port connection for everything. You should continue to do that for everything in this class. <br />

## Step 1: Updating multiple signals with one always_ff block

You may recall some experience with generating multiple signals (results) with a single always_comb block, although you needed to be careful of using a construct like this: <br />
```
          always_comb
            if (pb[0] == 0)
              red = pb[1];
            else
              green = pb[1];
```      
That would have resulted in an error because there was no alternative to assign to red when pb[0] was 1 and no alternative to assign to green when pb[0] was 0. The error would be expressed, cryptically, as "Latch inferred for signal \top.\red" because the design is specifying a storage of the red and green values when there is not something to assign to them in all cases. (Once again, we should be grateful that SystemVerilog even presents this warning, since a classic Verilog system lacked the "always_comb" keyword. You would have had only an "always" block which would have silently been converted to a latch.) <br />
With an always_ff block, there are greater freedoms. The expectation is that the elements that are modified are supposed to be storage elements. For instance, if you change the previous example to the following one: <br />
```
          always_ff @(posedge pb[3])
            if (pb[0] == 0)
              red <= pb[1];
            else
              green <= pb[1];
```    
First, note that we use the "<=" assignment because this is an always_ff block. This is going to be very important for this lab experiment. Really. Use "<=" within every always_ff block. <br />

Here, the '3' button acts as a clock. The green signal takes on the value of pb[1] on the rising edge of the clock only when the '0' button is pressed. The red signal takes on the value of pb[1] on the rising edge of the clock only when the '0' button is released. We don't need to specify values to assign to red and green at other times. They are expected to act as storage elements (flip-flops) and hold their values until they are updated. It is worth examining the hardware that is generated for such a specification. It looks like the following: <br />
[schematic for circuit 1](circuit1.png) <br />

Each flip-flop's D input is connected to the output of a multiplexer which maintains the current value of the flip-flop when the update conditions are not met. You may recall this to be the composition of a D flip-flop with an enable. This is how it is implemented when compiled into the FPGA, and is a more succinct way to represent the design: <br />
[schematic for circuit 2](circuit2.png) <br />

We reiterate the nature of the hardware specified by the Verilog design because... it is very important to remember that the goal of any good design is to get what you ask for. Keep this example in mind for the following lab experiment steps. <br />

## Step 1.1: Modify the digits module to contain multiple registers

Take the digits module that you constructed for the prelab, and the top module that you used to test it and hide the leading zeros. Change the digits module in the following ways:

- Create a new internal 32-bit logic signal named current that will be used as the storage for a number being entered instead of out as you did for the prelab.
- (Outside of the always_ff block) Unconditionally assign to out the value of current. This is just preparation for the next step. The out signal will still always show the number being entered.
- Create a new internal 32-bit logic signal named save that can be used to store an entered number.
- Create a new internal 4-bit logic signal named op that can be used to store a requested operation.
- Create a new internal 32-bit logic signal named result that will be used as the output of the selected arithmetic operation on the two entered values. <br />
This always_ff block now controls the update of current, save, and op. Each of them will be represented by flip-flops when they are converted to hardware. For some values of in, some of these signals will be updated. For others, only one of them will be updated. <br />

In the reset stanza of the always_ff block, initialize current, save, and op to zero. You should not assign anything to out (other than current), nor should you assign anything to result. These signals are driven by other logic. <br />
Now modify the casez (or nested-if) statement you used to select the activity to perform giving the value of the in signal: <br />

- **5'b0????:** Shift current left by four bits and assign its lower four bits to be the lower four bits of the in signal. This is simply implementing the shifting number entry scheme.
- **5'b10001:** This is the 'X' button. Shift the entered number to the right by four bits to delete the least significant digit.
- **5'b10010:** This is the 'Y' button which will be used to request an addition. For this operation, do two things: <br />
  - Assign to op the value 0 to indicate that an addition is being requested.
  - Assign to save the value of current.
- **5'b10011:** This is the 'Z' button which will be used to request a subtraction. For this operation, do two things: <br />
  - Assign to op the value 1 to indicate that a subtraction is being requested.
  - Assign to save the value of current.
- **5'b10000:** This is the 'W' button which will be used to represent the '=' sign. For this operation, assign to current the value of result. <br />
 <br />
**You used "<=" for all of those assignments, right?** <br />
 <br />
Create one more new module named math. Make it look like this:
```
          module math(input logic [3:0] op,
                      input logic [31:0] a,b,
                      output logic [31:0] r);
            always_comb
              case (op)
                0: r = a + b;
                1: r = a - b;
                default: r = 0;
              endcase
          endmodule
```      
And create an instance of it in the digits module like this:
```
          math m(.op(op), .a(save), .b(current), .r(result));
```      
Now, the result bus is always being driven with the result of the selected arithmetic operation and operands.
### Observe how it works

At this point, you've built everything needed to have a working calculator. Let's try it. Enter the following: <br />

          1 2 3   Y   X X X   4 5 6   W

The "1 2 3" enters hexadecimal number 12'h123 into current. The "Y" indicates an addition will happen, and it should store a 0 into op and copy the value in current into the save register. <br />

The "XXX" is needed to remove the value 123 from current so that it can be replaced with a new value. You might say that this is the worst calculator ever. ...Well, we can't just throw everything at you at once. Give it time, and we'll improve it. (Your instructor will also assure you that there have been worse calculators than this.) <br />

The "4 5 6" enters the hexadecimal number 12'h456 into current, so we now have 12'h123 in saved and 12'h456 in current. The value of op is 0, so the math instance is set up to add save and current together. The sum will be written to the result bus. When the 'W' button is pressed, the value on the result bus will be copied into the current bus. This will be displayed on the output. Hopefully, you should see the result "579" on the display. <br />
Test your modules carefully. When you are certain they are working, copy only the top and digits modules into the postlab text box for step 1. <br />

## Step 2: Improving the interface

It is not difficult to make the calculator act more like a real calculator should. We need only add one more bit of state. The problem to overcome is: <br />

- We don't want to have to delete the number we just entered when we press the add ('Y') or subtract ('Z') button. We should be able to just start typing the new number. <br />
Add the following signal, which will be represented as a flip-flop in the design: <br />
- Create a single-bit logic signal named show that will be used to decide which of current or save should be connected to out.
In the reset block of the always_ff, initialize show to be zero. <br />

Outside of your always_ff block, you should create either a dataflow statement or an always_comb block that does the following: <br />
```
        if show == 0:
          connect out to current
        else
          connect out to save
```      
This will cause the display to show either the value of the current register or the save register. <br />
Modify the actions in the rest of the always_ff that are based on the value of in as follows. These actions are presented in an order that describes how the actions should be undertaken: <br />

- **5'b10001:** ('X' button) No modifications.
- **5'b10010:** ('Y' button) Assign to op the value of 0 as before. In addition:
  - Only if show is zero:
    - Assign to save the value of current.
  - Assign to current the value 0.
  - Assign to show the value 1.
  What does this do? Effectively, it copies the current value into the save value, zeroes the current value, and displays the save value. There's a special case though. The value of current is only copied into save if show is set to display current. We'll explain why later.
- **5'b10011:** ('Z' button) Assign to op the value 1 to indicate subtraction as before. Then do everything else that was done for the 'Y' button to update current, save, and show.
- **5'b0????:** If the value of show says to display save, replace the entire value of current with 28'b0 concatenated with the lower four bits of in and set show to 0. Otherwise, incorporate the new digit into current as before. The idea is that, if an operation was previously entered, and the display set to show the save value, the display should now go back to showing the current register so that we can see what we're entering.
- **5'b10000:** ('W' button) Assign to save the value of result, as before. Also assign to show the value 1. This will cause the save value to be shown again. <br />
## Examples

All these details, and we only added one more bit of state to the system. <br />

There are lots of tedious details here, but the following examples should illustrate how you should expect the system to work. If it doesn't work like this, it means you have some modifications to make. Be patient, try each case, and correct any mistakes. <br />

Reset the system (with 3-0-W), and type the following: <br />

- `1 2 3 Y = 123`
  This will enter 123 into current, copy it into save, update show to 1 so that save is displayed on out. "123" should still be visible on the display. <br />
- `4 5 6 = 456`
  The instant that "4" is pressed, it will be shifted into previously zeroed current and show will be updated to display current on the out bus. The end result will be that "456" will be viewed on the display. <br />
- `W = 579`
  The math instance is always updating the result bus, and when the 'W' is pressed, the value of result will be copied into save, overwriting the previous value, and show will be updated to 1 to show the contents of the save register. The end result is that "579" should be shown on the display. (123 + 456 = 579). <br />

Reset the system (with 3-0-W), and type the following: <br />

- `4 Y 1 W W W W = 8 `
  This will cause 4 to be loaded into current. The 'Y' will cause it to be moved into save. The value 1 will go into current, and the 'W' will add 4 + 1 = 5. Each subsequent 'W' will repeat the previous operation (+ 1). The end result should be that 8 is shown. <br />
- `Z 1 W W W = 5 `
  Since 'W' was the last thing pressed, show is set to 1. When 'Z' is pressed next, the value of current is not copied into save. Instead, the value of save remains the same, and the following '1' is shifted into the now zero current. The following 'W' will cause the current value to be subtracted from save. The new result will be copied into save. Because 'W' is pressed three times, the operation is repeated three times. The end result is that 5 is shown on the display.
This example illustrates standard behavior for classic calculators. Pressing '=' repeats the last-requested operation with the last-entered operand on a saved value. If you have an old calculator (or some kinds of calculator programs), you should see the same behavior. Our "equal" sign is the 'W' button, and you will find that repeatedly pressing 'W' will be helpful for testing the calculator design. <br />

Reset the system (with 3-0-W), and type the following:

- `1 Z 1 W W = FFFFFFFF`
  This will cause the value 1 to be entered, 1 subtracted, and then 1 subtracted again. In 32-bit two's-complement arithmetic, 0 - 1 is 32'b11111111111111111111111111111111. In hexadecimal, this is shown as FFFFFFFF.

Reset the system (with 3-0-W), and type the following:

- `C Y 1 W W W W = 10 `
  This will cause the value C to be entered, and 1 added four times. It should display 10. (No, this is not a typo. Remember: It's hexadecimal. C + 4 = 10)
- `Y 1 0 W W W W W W W = 80 `
  This will replace the value in current with 10, and repeat the previously selected operation (addition) seven times. In this case, we're not starting a new operation. We're just continuing the old operation with a new operand. It should display 80.
Test these changes carefully. It's not a lot of typing, but it's a great deal of reading and understanding. Think about the flip-flops and next-state mechanisms that are created when you compile a design like this. If you can imagine every expression as a collection of multiplexers and flip-flops, you can understand how it is manifested as an FPGA implementation. <br />

When your design works, copy only the updated digits module into the text box for step 2 in the postlab submission. <br />

## Step 3: Improving the interface one step further

One more unrealistic aspect of the calculator is that you can continue entering digits even after all eight displays are filled. It should not be possible to continue pressing buttons and scrolling the number once eight digits have been entered. Correcting this problem is a little more difficult than the others, so we left it for last. Once again, we need to add more bits of state to the design. These will be updated by the always_ff block. <br />

- Create an eight-bit logic signal named full that will be used as an indicator of which digits have non-zero values in them. It will be updated within the always_ff block, and it will be used to decide how actions given by the in signal should be interpreted. <br />
Because full is modified by the always_ff block, you should be sure to initialize it to zero in the reset section.  <br />

The modifications to make to the always_ff block actions for in from the previous step are as follows. We'll list the easy ones first: <br />

- **5'b10000:** ('W' button) Set full to zero.
- **5'b10010:** ('Y' button) When an operation is selected, we save the current value into the save register, and we're ready to input a new value into current. We want to indicate that none of the digits of current have information, so set full to 0.
- **5'b10011:** ('Z' button) Same as for the 'Y' button.
- **5'b0????:** (any digit, 0-F) We want to shift one new digit into current so we should shift a '1' into the full register. It acts as a shift register. We need to be careful not to shift it if the number we enter is a leading zero. e.g., there should be no restriction to you entering the number 0000000012345678. The leading zeros should not matter.

There are two cases here:  <br />
- For the case where show is initially 1, we're starting entry of a new number after selecting an operation (such as addition). Set full to 8'b00000001 only if the new digit is not zero. In this case any new digit (even zero) can be shifted into the current register.  <br />
- For the case where show is initially 0, we're either starting to enter the first number of an expression or continuing to enter a number that's already started. Again, if we start off entering zero digits, we want to ignore them, but we don't want to ignore zero digits if there are non-zero leading digits (e.g., 1000). We should only shift '1' bits into full if at least one digit has been shifted in (full[0] == 1) or if the new digit is non-zero (in != 0). Here is where we need to make sure we don't allow more than 8 digits. Do so something like this: <br />
  ```
                    if full is not 8'b11111111:
                        shift the new digit into current
                        if full[0] == 1 or in != 0:
                            full <= {full[6:0],1'b1}
  ```              
  There are many ways of expressing this more succinctly. You can certainly come up with one if you give it a few minutes of thought. <br />
- **5'b10001:** ('X' button) We want to backspace by one digit. This means we should shift the full register right by one position and make the new leftmost bit 0. Do this only if full is not already zero.

## Examples

Once again, here are some examples to make sure you implement this correctly. We're going to do the same operations when we test your module. <br />

Reset the system (with 3-0-W), and type the following:

- `0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 9 9 9 = 12345678`
  The leading zeros should be ignored, but 12345678 should appear. The further entry of numbers should not be permitted, so the 9 9 9 will be ignored.
- `X X X X X = 123`
  This backspace by five digits and show 123.
- `8 7 6 5 4 3 2 1 = 12387654`
  This will permit five new digits (87654) to be shifted in. Subsequent digits (321) should be ignored. The end result is that 12387654 is shown.

Reset the system (with 3-0-W), and type the following: <br />

- `0 7 0 Y = 70`
  Just set it up with an initial number and prepare to add a second one. The value 70 should be displayed.
- `0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 9 9 9 = 12345678`
  Check that entry of the second number ignores leading zeros and accepts only eight new digits.
- `W = 123456E8`
  Make sure that the two hexadecimal numbers (70) and (12345678) are added properly. The result, 123456E8 should be shown.

Reset the system (with 3-0-W), and type the following:
- `0 1 Y 0 1 W W W = 4`
  Enter 1 and add 1 to it 3 times to display 4.
- `X X X X W W W W = 8`
  Make sure that backspace does not affect the value in current after pressing 'W' in the previous step.

Whew... Lots of details and examples. <br />

Again, this system is just flip-flops and next-state equations implemented with multiplexers. As more and more state logic is added to the system, it becomes more difficult to see those flip-flops and muxes, but you should still try. The better you understand the hardware that is produced for a Verilog specification, the easier it will be for you to get the result you ask for.  <br />

Test your design thoroughly. Check the examples carefully. When you are satisfied it is working correctly, copy and paste only the digits module into the text box for step 3 in the postlab submission. <br />

## Step 4: Just for fun

It may not be your idea of "fun", but you're at the point where you can try something interesting now. Replace the functionality for 'X' in your digits always_ff block with the same mechanisms for 'Y' and 'Z' except assign op <= 2. In the math module, add another entry to the case statement for when op is 2: <br />

          `2: r = a * b;`

After doing this, you won't be able to backspace entered numbers anymore, but you will have a calculator that can multiply 32-bit hexadecimal numbers. Notice that it takes longer to compile your design in the simulator now. You might also try replacing the '*' with '/' to make a calculator that can divide a 32-bit hexadecimal number by another. This will take a long time to compile—so long that the simulator might give up waiting for it to finish and just call it an error.
>Questions or comments about the course and/or the content of these webpages should be sent to the Course Webmaster. All the materials on this site are intended solely for the use of students enrolled in ECE 270 at the Purdue University West Lafayette Campus. Downloading, copying, or reproducing any of the copyrighted materials posted on this site (documents or videos) for anything other than educational purposes is forbidden.
