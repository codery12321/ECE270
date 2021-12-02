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
  logic [3:0]disp7, disp6, disp5, disp4;
  logic [7:0] sum, diff;

  ssdec s4(.in(disp4), .out(ss4[6:0]), .enable(1'b1));
  ssdec s5(.in(disp5), .out(ss5[6:0]), .enable(1'b1));
  ssdec s6(.in(disp6), .out(ss6[6:0]), .enable(1'b1));
  ssdec s7(.in(disp7), .out(ss7[6:0]), .enable(1'b1));

  always_ff @ (posedge pb[7], posedge reset)
    if(reset)
      disp7 <= 4'b0;
    else begin
      disp7 <= disp7 + 4'b0001;
    end
  always_ff @ (posedge pb[6], posedge reset)
    if(reset)
      disp6 <= 4'b0;
    else begin
      disp6 <= disp6 + 4'b0001;
    end
  always_ff @ (posedge pb[5], posedge reset)
    if(reset)
      disp5 <= 4'b0;
    else begin
      disp5 <= disp5 + 4'b0001;
    end
  always_ff @ (posedge pb[4], posedge reset)
    if(reset)
      disp4 <= 4'b0;
    else begin
      disp4 <= disp4 + 4'b0001;
    end
  logic [7:0] in1, in2;
  always_comb begin
    in1 = {disp7, disp6};
    in2 = {disp5, disp4};

    sum = in1 + in2;
    diff = in1 - in2;
  end

  ssdec s0(.in(diff[3:0]), .out(ss0[6:0]), .enable(1'b1));
  ssdec s1(.in(diff[7:4]), .out(ss1[6:0]), .enable(1'b1));
  ssdec s2(.in(sum[3:0]), .out(ss2[6:0]), .enable(1'b1));
  ssdec s3(.in(sum[7:4]), .out(ss3[6:0]), .enable(1'b1));

  always_comb begin
    right[7] = sum[7] == 1'b1 ? 1'b1 : 1'b0;//N flag for addition
    right[6] = sum == 0 ? 1'b1: 1'b0; //~(|out); //Z flag for addition
    right[3] = diff[7] == 1'b1 ? 1'b1 : 1'b0;//N flag for subtraction
    right[2] = diff == 0 ? 1'b1: 1'b0; //~(|out);//Z flag for subtraction
    //right = 8'b0;
    if ((in1[7] == 1 && in2[7] == 1) || (in1[7] == 1 && sum[7] == 0) || (in2[7] == 1 && sum[7] == 0))//C flag for addition
      right[5] = 1'b1;
    else
      right[5] = 1'b0;
    if ((in1[7] == 1 && in2[7] == 1 && sum[7] == 0) || (in1[7] == 0 && in2[7] == 0 && sum[7] == 1)) //V flag for addition
      right[4] = 1'b1;
    else
      right[4] = 1'b0;
    if ((in1[7] == 1 && in2[7] == 0) || (in1[7] == 1 && diff[7] == 0) || (in2[7] == 0 && diff[7] == 0))//C flag for subtraction
      right[1] = 1'b1;
     else
      right[1] = 1'b0;
    if ((in1[7] == 1 && in2[7] == 0 && diff[7] == 0) || (in1[7] == 0 && in2[7] == 1 && diff[7] == 1)) //V flag for subtraction
      right[0] = 1'b1;
    else
      right[0] = 1'b0;
  end
endmodule

// Add more modules down here...
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
