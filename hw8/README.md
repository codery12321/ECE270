# Homework 8
## Step 1: Counter next-state equations
Create a SystemVerilog module named inc4 that accepts a 4-bit input named 'in' and produces a 4-bit output named 'out'. In this module, implement the counter equations to produce an output that is the next binary number higher than the input. When the input is 4'b1111, the output should "wrap-around" to 4'b0000.

Put the following statements in the top module to test your inc4 module:
```
  logic clk;
  div100 d(.in(hz100), .reset(reset), .out(clk));
  logic [3:0] q, next_q;
  always_ff @(posedge clk)
    q <= next_q;
  inc4 i(.in(q), .out(next_q));
  ssdec s0(.out(ss0[6:0]), .in(q), .enable(1));
  ```
And add the following module below to implement the divide-by-100 operation.
```
module div100(input logic in, reset, output logic out);
  logic [99:0] shift;
  always_ff @(posedge in, posedge reset)
    if (reset)
      shift <= 100'b1;
    else
      shift <= {shift[98:0],shift[99]};
  assign out = shift[99];
endmodule
```
Use the ssdec module you used for previous assignments.

The main reset signal will be used to initialize the div100 shift register to contain an initial 100'b1. Thereafter, it will produce a 1 Hz output. That 1 Hz signal is connected to the clk signal and is used as a clock for the always_ff block. The only thing done by the always_ff is synchronously update all four bits of the q bus with the contents of the next_q bus. The next_q bus is set by the output of your inc4 module.

This is the simplest specification for only the next-state equations for generation of a four-bit counter.

Test your module carefully to ensure that it counts from 0 up to F and back to 0. When it works as you expect, copy only the inc4 module into the textbox below.

## Step 2: A counter with an asynchronous reset
Consider lecture module 3-F pages 9–28.
Construct a four-bit counter module named "counter4ar" that has only a clock input named "clk", a four bit output named "out", and an asynchronous reset named "ar". Create an instance of it in your top module with the following statements:

  ```
  logic clk;
  div100 d(.in(hz100), .reset(reset), .out(clk));
  logic [3:0] count;
  counter4ar c(.out(count), .clk(clk), .ar(pb[19]));
  ssdec s0(.out(ss0[6:0]), .in(count), .enable(1));
  ```
Use the **div100** and **ssdec** modules as you did for the the previous question. The ss0 digit should increment once per second from 0 up to F, and repeat starting with 0 again. The asynchronous input, "ar", is connected to pb[19] (the 'Z' button). The instant the 'Z' button is pressed, the display should show a '0' and remain at '0' as long as the 'Z' button is held.
This is the nature of an asynchronous reset. It does not wait for the rising edge of the clock to take effect. To implement an asynchronous reset, you must build the functionality into the always_ff block of the counter.

Copy and paste only the **counter4ar** module into the box below. There are no other modules to write for this question.

## Step 3: A counter with a synchronous reset
Construct a four-bit counter module named "counter4sr" that has only a clock input named "clk", a four bit output named "out", and a synchronous reset named "sr". Create an instance of it in your top module with the following statements:

  ```
  logic clk;
  div100 d(.in(hz100), .reset(reset), .out(clk));
  logic [3:0] count;
  counter4sr c(.out(count), .clk(clk), .sr(pb[18]));
  ssdec s0(.out(ss0[6:0]), .in(count), .enable(1));
  ```
Use the **div100** and **ssdec** modules as you did for the the previous questions. The ss0 digit should increment once per second from 0 up to F, and repeat starting with 0 again. The synchronous input, "sr", is connected to pb[18] (the 'Y' button). When the 'Y' button is pressed and held, the display will change to a '0' on the next rising edge of the clock.
This is the nature of a synchronous reset. It waits for the rising edge of the clock to take effect. A synchronous reset is not part of the always_ff part of the counter. It is a modification of the purely combinational next-state logic. It is possible to implement this by creating more if - else constructs in the always_ff block, but it should not appear in the sensitivity list of the always_ff statement.

Copy and paste only the **counter4sr** module into the box below. There are no other modules to write for this question.

## Step 4: A counter with no resets and an enable input
Construct a four-bit counter module named "counter4en" that has only a clock input named "clk", a four bit output named "out", and an enable input named "en".

Note that this counter has no reset mechanism at all. We are relying on the notion that all elements of the FPGA are initialized to zero. This is not a very good assumption, but we're trying to keep it simple. Let's go with that just for this exercise.

Create an instance of it in your top module with the following statements:

  ```
  logic clk;
  div100 d(.in(hz100), .reset(reset), .out(clk));
  logic [3:0] count;
  counter4en c(.out(count), .clk(clk), .en(pb[17]));
  ssdec s0(.out(ss0[6:0]), .in(count), .enable(1));
  ```
Use the **div100** and **ssdec** modules as you did for the the previous questions. The "en" input is connected to pb[17] (the 'X' push button). As long as pb[17] is not asserted, the counter remains at zero. As long as pb[17] is asserted, the ss0 digit should increment once per second from 0 up to F, and repeat starting with 0 again. If the 'X' button is released, counting should pause. Pressing it again will cause the count to resume.

Because the "en" input is not an asynchronous signal, it should not appear in the sensitivity list of the of the always_ff statement. You can think of it as a modification of the next-state logic. It is possible to implement this with additional if - else statements inside the always_ff block, but it is best thought of as a modification of the purely combinational next-state equations.

Copy and paste only the **counter4en** module into the box below. There are no other modules to write for this question.
