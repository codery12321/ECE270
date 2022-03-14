
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
  logic [3:0] in4;
  logic strobe;
  logic [3:0] out4;
  enc16to4 e(.in(pb[15:0]), .out(in4), .strobe(strobe));
  map4 m(.in(in4), .out(out4));
  ssdec s(.in(out4), .out(ss0[6:0]), .enable(strobe));

  
endmodule

// Add more modules down here...
module map4 (input logic [3:0]in,output logic [3:0]out);
  always_comb begin
    case (in)
        4'h0: out = 4'hb;
        4'h1: out = 4'h3;
        4'h2: out = 4'h7;
        4'h3: out = 4'h8;
        4'h4: out = 4'h1;
        4'h5: out = 4'hf;
        4'h6: out = 4'h0;
        4'h7: out = 4'hd;
        4'h8: out = 4'h2;
        4'h9: out = 4'he;
        4'ha: out = 4'h5;
        4'hb: out = 4'h4;
        4'hc: out = 4'h9;
        4'hd: out = 4'ha;
        4'he: out = 4'h6;
        4'hf: out = 4'hc;
    endcase
  end
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

module enc16to4 (input logic [15:0]in, output logic [3:0]out, output logic strobe);
  
  assign strobe = |in[15:0];
  assign out[3] = (in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9]| in[8]);
  assign out[2] = (in[15] | in[14] | in[13] | in[12] | in[7] | in[6] | in[5] | in[4]);
  assign out[1] = (in[15] | in[14] | in[11] | in[10] | in[7] | in[6] | in[3] | in[2]);
  assign out[0] = (in[15] | in[13] | in[11] | in[9] | in[7] | in[5] | in[3] | in[1]);
  
  
endmodule


