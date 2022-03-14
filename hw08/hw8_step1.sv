/*Create a SystemVerilog module named inc4 that accepts a 4-bit input named 'in' and produces a 4-bit output named 'out'. In this module, implement the counter equations to produce an output that is the next binary number higher than the input. When the input is 4'b1111, the output should "wrap-around" to 4'b0000.

Put the following statements in the top module to test your inc4 module:

  logic clk;
  div100 d(.in(hz100), .reset(reset), .out(clk));
  logic [3:0] q, next_q;
  always_ff @(posedge clk)
    q <= next_q;
  inc4 i(.in(q), .out(next_q));
  ssdec s0(.out(ss0[6:0]), .in(q), .enable(1));
And add the following module below to implement the divide-by-100 operation.
module div100(input logic in, reset, output logic out);
  logic [99:0] shift;
  always_ff @(posedge in, posedge reset)
    if (reset)
      shift <= 100'b1;
    else
      shift <= {shift[98:0],shift[99]};
  assign out = shift[99];
endmodule
Use the ssdec module you used for previous assignments.
The main reset signal will be used to initialize the div100 shift register to contain an initial 100'b1. Thereafter, it will produce a 1 Hz output. That 1 Hz signal is connected to the clk signal and is used as a clock for the always_ff block. The only thing done by the always_ff is synchronously update all four bits of the q bus with the contents of the next_q bus. The next_q bus is set by the output of your inc4 module.

This is the simplest specification for only the next-state equations for generation of a four-bit counter.

Test your module carefully to ensure that it counts from 0 up to F and back to 0. When it works as you expect, copy only the inc4 module into the textbox below.
*/

`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // Your code goes here...
  logic clk;
  div100 d(.in(hz100), .reset(reset), .out(clk));
  logic [3:0] q, next_q;
  always_ff @(posedge clk)
    q <= next_q;
  inc4 i(.in(q), .out(next_q));
  ssdec s0(.out(ss0[6:0]), .in(q), .enable(1));

endmodule

// Add more modules down here...
module inc4(input logic [3:0]in, output logic [3:0] out);
  /*always_comb
    out = in + 1;*/

  always_comb begin //next-state equations
    out[0] = ~in[0];
    out[1] = in[1] ^ in[0];
    out[2] = in[2] ^ (&in[1:0]);
    out[3] = in[3] ^ (&in[2:0]);
  end
endmodule

module div100(input logic in, reset, output logic out);
  logic [99:0] shift;
  always_ff @(posedge in, posedge reset)
    if (reset)
      shift <= 100'b1;
    else
      shift <= {shift[98:0],shift[99]};
  assign out = shift[99];
endmodule

module ssdec (input logic [3:0]in, output logic [6:0] out, input logic enable);
    logic [6:0] SEG7 [15:0];

    assign SEG7[4'h0] = enable == 1 ? 7'b0111111: 7'b0000000;//012345
    assign SEG7[4'h1] = enable == 1 ? 7'b0000110: 7'b0000000;//12
    assign SEG7[4'h2] = enable == 1 ? 7'b1011011: 7'b0000000;//01346
    assign SEG7[4'h3] = enable == 1 ? 7'b1001111: 7'b0000000;//01236
    assign SEG7[4'h4] = enable == 1 ? 7'b1100110: 7'b0000000;//1256
    assign SEG7[4'h5] = enable == 1 ? 7'b1101101: 7'b0000000;//02356
    assign SEG7[4'h6] = enable == 1 ? 7'b1111101: 7'b0000000;//023456
    assign SEG7[4'h7] = enable == 1 ? 7'b0000111: 7'b0000000;//012
    assign SEG7[4'h8] = enable == 1 ? 7'b1111111: 7'b0000000;//0123456
    assign SEG7[4'h9] = enable == 1 ? 7'b1100111: 7'b0000000;//01256
    assign SEG7[4'ha] = enable == 1 ? 7'b1110111: 7'b0000000;//012456
    assign SEG7[4'hb] = enable == 1 ? 7'b1111100: 7'b0000000;//23456
    assign SEG7[4'hc] = enable == 1 ? 7'b0111001: 7'b0000000;//0345
    assign SEG7[4'hd] = enable == 1 ? 7'b1011110: 7'b0000000;//12346
    assign SEG7[4'he] = enable == 1 ? 7'b1111001: 7'b0000000;//03456
    assign SEG7[4'hf] = enable == 1 ? 7'b1110001: 7'b0000000;//0456

    assign {out[6:0]} = SEG7[in];
endmodule
