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
  prienc16to4 u1(.in(pb[15:0]), .out(right[3:0]), .strobe(green));

endmodule

// Add more modules down here...
module prienc16to4(input logic [15:0] in, output logic [3:0] out, output logic strobe);
  assign {out, strobe} = in[15] == 1 ? 5'b11111 :
                         in[14] == 1 ? 5'b11101 :
                         in[13] == 1 ? 5'b11011 :
                         in[12] == 1 ? 5'b11001 :
                         in[11] == 1 ? 5'b10111 :
                         in[10] == 1 ? 5'b10101 :
                         in[9] == 1 ? 5'b10011 :
                         in[8] == 1 ? 5'b10001 :
                         in[7] == 1 ? 5'b01111 :
                         in[6] == 1 ? 5'b01101 :
                         in[5] == 1 ? 5'b01011 :
                         in[4] == 1 ? 5'b01001 :
                         in[3] == 1 ? 5'b00111 :
                         in[2] == 1 ? 5'b00101 :
                         in[1] == 1 ? 5'b00011 :
                         in[0] == 1 ? 5'b00011 :
                         5'b00000 ;

endmodule
