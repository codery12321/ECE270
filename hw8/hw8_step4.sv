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
  logic [3:0] count;
  counter4en c(.out(count), .clk(clk), .en(pb[17]));
  ssdec s0(.out(ss0[6:0]), .in(count), .enable(1));
endmodule

// Add more modules down here...
module counter4en(input logic clk, input logic en, output logic [3:0] out);
logic [3:0] next_out;
  always_ff @ (posedge clk)
      if (en == 1'b0)
      out <= 4'b0;
      else 
      out <= next_out;
  always_comb begin
      next_out[0] = ~out[0];
      next_out[1] = out[1] ^ out[0];
      next_out[2] = out[2] ^ (&out[1:0]);
      next_out[3] = out[3] ^ (&out[2:0]);
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