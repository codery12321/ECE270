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
	enc16to4 u1(.in(pb[15:0]), .out(right[3:0]), .strobe(green));

endmodule

// Add more modules down here...
module enc16to4 ( input logic [15:0]in, output logic [3:0]out, output logic strobe);

  assign strobe = |in[15:0];
  assign out[3] = (in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9]| in[8]);
  assign out[2] = (in[15] | in[14] | in[13] | in[12] | in[7] | in[6] | in[5] | in[4]);
  assign out[1] = (in[15] | in[14] | in[11] | in[10] | in[7] | in[6] | in[3] | in[2]);
  assign out[0] = (in[15] | in[13] | in[11] | in[9] | in[7] | in[5] | in[3] | in[1]);

  //how do I write the above code in one line connected to one ouput?
  //I can't write it like this
  /*
  assign out[3] = |(in[15:8]); //this works but others don't
  assign out[2] = |(in[15:12] in[7:4]);
  assign out[1] = |(in[15:14] in[13:12] in[7:6] in[3:2]);
  */

endmodules
