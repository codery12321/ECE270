
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
  logic [4:0] keycode;
  logic strobe;
  scankey sk1 (.clk(hz100), .rst(reset), .in(pb[19:0]), .strobe(strobe), .out(keycode));
  logic [31:0] data;
  digits d1 (.in(keycode), .out(data), .clk(strobe), .reset(reset));

  ssdec s0(.in(data[3:0]),   .out(ss0[6:0]), .enable(1'b1));
  ssdec s1(.in(data[7:4]),   .out(ss1[6:0]), .enable(|data[31:4]));
  ssdec s2(.in(data[11:8]),  .out(ss2[6:0]), .enable(|data[31:8]));
  ssdec s3(.in(data[15:12]), .out(ss3[6:0]), .enable(|data[31:12]));
  ssdec s4(.in(data[19:16]), .out(ss4[6:0]), .enable(|data[31:16]));
  ssdec s5(.in(data[23:20]), .out(ss5[6:0]), .enable(|data[31:20]));
  ssdec s6(.in(data[27:24]), .out(ss6[6:0]), .enable(|data[31:24]));
  ssdec s7(.in(data[31:28]), .out(ss7[6:0]), .enable(|data[31:28]));
endmodule

// Add more modules down here...
module digits(input logic [4:0]in, output logic [31:0] out, output logic clk, input logic reset);
  logic [31:0] nextout;
  
  always_ff @ (posedge clk, posedge reset)
  if(reset)
    out <= 32'b0;
  else
    out <= nextout;
  
  always_comb begin
    casez(in)
      5'b0????: nextout = (out << 4) | {28'b0, in[3:0]};
      5'b10000: nextout = 32'b0; 
      5'b10001: nextout = {4'b0, out [31:4]};
      5'b10010: nextout = out + 1;
      default: nextout = out - 1; //5'b10011
    endcase
  end
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

