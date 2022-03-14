
`default_nettype none\
// Empty top module\
\
module top (\
  // I/O ports\
  input  logic hz100, reset,\
  input  logic [20:0] pb,\
  output logic [7:0] left, right,\
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,\
  output logic red, green, blue,\
\
  // UART ports\
  output logic [7:0] txdata,\
  input  logic [7:0] rxdata,\
  output logic txclk, rxclk,\
  input  logic txready, rxready\
  \
);\
\
  // Your code goes here...\
  mux4to1 u1(.sel(pb[1:0]), .d(pb[7:4]), .y(green));\
endmodule\
\
module mux4to1 (\
  output logic y,\
  input logic [3:0]d,\
  input logic [1:0]sel\
  );\
  assign y = (~sel[1] & ~sel[0] & d[0] | \
               sel[1] & ~sel[0] & d[1] |\
              ~sel[1] &  sel[0] & d[2] |\
               sel[1] &  sel[0] & d[3]);\
endmodule\
// Add more modules down here...\
}
