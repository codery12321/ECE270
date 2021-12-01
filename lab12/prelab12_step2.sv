
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
  faha f1(.a(pb[0]), .b(pb[1]), .ci(pb[2]), .s(right[0]), .co(right[1]));
endmodule

// Add more modules down here...
module faha (input logic a, b, ci, output logic s, co);

  logic h1_s, h2_s, h1_co, h2_co;

  ha h1(.a(a), .b(b), .s(h1_s), .co(h1_co));
  ha h2(.a(ci), .b(h1_s), .s(h2_s), .co(h2_co));
  assign s = h2_s;
  assign co = h1_co | h2_co;

endmodule

module ha (input logic a, b, output logic s, co);
  assign s = a ^ b;
  assign co = a & b;
endmodule
