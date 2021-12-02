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
  logic [3:0]temp;
  assign temp[3] = right[3];
  assign temp[2] = right[2];
  assign temp[1] = right[1];
  assign temp[0] = right[0];
  
  // Your code goes here...
  hc74_set set(.sn(pb[16]), .c(pb[0]), .q(temp[0]), .d(temp[3]));
  hc74_reset r1(.rn(pb[16]), .c(pb[0]), .q(temp[1]), .d(temp[0]));
  hc74_reset r2(.rn(pb[16]), .c(pb[0]), .q(temp[2]), .d(temp[1]));
  hc74_reset r3(.rn(pb[16]), .c(pb[0]), .q(temp[3]), .d(temp[2]));
endmodule

// Add more modules down here...

// This is a single D flip-flop with an active-low asynchronous reset (clear).
// It has no asynchronous set because the simulator does not allow it.
// Other than the lack of a set, it is half of a 74HC74 chip.

module hc74_reset(input logic d, c, rn,
                  output logic q, qn);
  assign qn = ~q;
  always_ff @(posedge c, negedge rn)
    if (rn == 1'b0)
      q <= 1'b0;
    else
      q <= d;
endmodule

// This is a single D flip-flop with an active-low asynchronous set (preset).
// It has no asynchronous reset because the simulator does not allow it.
// Other than the lack of a reset, it is half of a 74HC74 chip.
module hc74_set(input logic d, c, sn,
                  output logic q, qn);
  assign qn = ~q;
  always_ff @(posedge c, negedge sn)
    if (sn == 1'b0)
      q <= 1'b1;
    else
      q <= d;
endmodule

