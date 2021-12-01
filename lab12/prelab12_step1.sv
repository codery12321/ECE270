
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
  ha h1(.a(pb[0]), .b(pb[1]), .s(right[0]), .co(right[1]));
endmodule

// Add more modules down here...
module ha (input logic a, b, output logic s, co);
  assign s = a ^ b;
  assign co = a & b;
endmodule