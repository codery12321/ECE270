
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
support13 sup (.clk (hz100), .reset (reset), .in (pb), .out7 (ss7), .out6 (ss6), .out5 (ss5), .out4 (ss4), .out3 (ss3), .out2 (ss2), .out1 (ss1), .out0 (ss0));
  // Your code goes here...
  
endmodule

// Add more modules down here...
module alu (
  input logic clk, rst,         // clk and rst for handling flag updation
  input logic [31:0] in1, in2,  // the operands the ALU will act on,
  input logic fue,              // the Flag Update Enable, which, if high, 
                                // allows fout to be updated on rising edge of clk
  input logic [4:0] op,         // the current operation,
  output logic [31:0] out,      // the result of the current operation,
  output logic [3:0] fout       // the flags of the current operation.
);
logic Ncur, Zcur, Ccur, Vcur;
assign Ncur = fout[3];
assign Zcur = fout[2];
assign Ccur = fout[1];
assign Vcur = fout[0];

logic N, Z, C, V;

logic [3:0]nfout;
always_comb begin
  case (op) 
    ALU_CMP: begin out = in1 - in2; nfout = {N, Z, C, V}; end
    ALU_NEG: begin out = 0 - in2; nfout = {N, Z, C, V}; end
    ALU_ADD: begin out = in1 + in2;  nfout = {N, Z, C, V}; end
    ALU_ADC: begin out = in1 + in2 + {31'b0, Ccur}; nfout = {N, Z, C, V}; end
    ALU_SUB: begin out = in1 - in2; nfout = {N, Z, C, V}; end
    ALU_SBC: begin out = in1 - in2 + {31'b0, Ccur}; nfout = {N, Z, C, V}; end
    ALU_NOT: begin out = ~in2; nfout = {N, Z, Ccur, Vcur}; end
    ALU_OR : begin out = in1 | in2; nfout = {N, Z, Ccur, Vcur}; end
    ALU_AND: begin out = in1 & in2; nfout = {N, Z, Ccur, Vcur}; end
    ALU_BIC: begin out = in1 & ~in2; nfout = {N, Z, Ccur, Vcur}; end
    ALU_XOR: begin out = in1 ^ in2; nfout = {N, Z, Ccur, Vcur}; end
    ALU_CPY: begin out = in2; nfout = {N, Z, Ccur, Vcur}; end
    default: begin out = 0; nfout = {Ncur, Zcur, Ccur, Vcur}; end
  endcase
  N = out[31] == 1'b1 ? 1'b1 : 1'b0;
  Z = out == 0 ? 1'b1: 1'b0; //~(|out);
  if(op == ALU_ADD || op == ALU_ADC) begin
    if ((in1[31] == 1 && in2[31] == 1) || (in1[31] == 1 && out[31] == 0) || (in2[31] == 1 && out[31] == 0)) //C flag for addition
      C = 1'b1;
    else
      C = 1'b0;
  end
  else if(op == ALU_SUB || op == ALU_SBC) begin
    if ((in1[31] == 1 && in2[31] == 0) || (in1[31] == 1 && out[31] == 0) || (in2[31] == 0 && out[31] == 0)) //C flag for subtraction
      C = 1'b1;
    else
      C = 1'b0;
  end
  else
    C = 1'b0;
  
  if(op == ALU_ADD || op == ALU_ADC) begin
    if((in1[31] == 1 && in2[31] == 1 && out[31] == 0) || (in1[31] == 0 && in2[31] == 0 && out[31] == 1) ) //V flag for addition
      V = 1'b1;
    else
      V = 1'b0;
  end
  else if (op == ALU_SUB || op == ALU_SBC) begin
    if ((in1[31] == 1 && in2[31] == 1 && out[31] == 0) || (in1[31] == 0 && in2[31] == 1 && out[31] == 1)) //V flag for subtraction
      V = 1'b1;
    else
      V = 1'b0;
  end
  else
    V = 1'b0;
end

always_ff @ (posedge rst, posedge clk)
if (rst)
  fout <= 0;
else if (fue == 1)
  fout <= nfout;
  
endmodule

module scankey(input logic clk, input logic rst, input logic [19:0] in, output logic [4:0] out, output logic strobe);
  assign out[0] = in[1] | in[3] | in[5] | in[7] | in[9]  | in[11] | in[13] | in[15] | in[17] | in[19];
  assign out[1] = in[2] | in[3] | in[6] | in[7] | in[10] | in[11] | in[14] | in[15] | in[18] | in[19];
  assign out[2] = in[4] | in[5] | in[6] | in[7] | in[12] | in[13] | in[14] | in[15];
  assign out[3] = in[8] | in[9] | in[10] | in[11] | in[12] | in[13] | in[14] | in[15];
  assign out[4] = in[16] | in[17] | in[18] | in[19];
  logic delay0, delay1;
  logic [3:0] next_out;
  always_ff @ (posedge clk, posedge rst) begin
    if(rst) begin
    delay0 <= 0;
    delay1 <= 0;
    end
    else begin
    delay0 <= |in[19:0];
    delay1 <= delay0;
    end
  end
  assign strobe = delay1;
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