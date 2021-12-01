
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
  fa4 f1(.a(pb[3:0]), .b(pb[7:4]), .ci(pb[19]), .s(right[3:0]), .co(right[4]));
endmodule

// Add more modules down here...
module fa4(input logic [3:0]a, b, input logic ci, output logic [3:0] s, output logic co);
  logic co1, co2, co3;

  fa f1(.a(a[0]), .b(b[0]), .ci(ci), .s(s[0]), .co(co1));
  fa f2(.a(a[1]), .b(b[1]), .ci(co1), .s(s[1]), .co(co2));
  fa f3(.a(a[2]), .b(b[2]), .ci(co2), .s(s[2]), .co(co3));
  fa f4(.a(a[3]), .b(b[3]), .ci(co3), .s(s[3]), .co(co));
endmodule

module fa (input logic a, b, ci, output logic s, co);
  assign s = a ^ b ^ ci;
  assign co = a &b | a&ci | b&ci;
endmodule