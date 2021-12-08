
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
  //STEP 1
  logic enable, next;
  assign ss7[7] = enable;
  always_ff @ (posedge pb[1])
    if (pb[19])
      enable <= 1'b0;
    else if (pb[1])
      enable <= enable + 1'b1;
    else
      enable <= next;
  //STEP 2
  logic [16:0]shift;
  assign {left[7:0], red, right[7:0]} = shift;
  always_ff @ (posedge hz100, posedge reset)
    if (reset)
      shift <= 17'b0;
    else if (enable) begin
        if (shift[16] == 1'b1)
            shift <= 17'b0;
        else
          shift <= (shift << 1) | {16'b0, 1'b1};
    end

  //STEP3 
  logic [3:0] count0;
  ssdec s0(.in(count0), .out(ss0[6:0]), .enable(1'b1));
  always_ff @ (posedge shift[16], posedge reset)
  if(reset) begin
    count0 <= 4'b0;
    en <= 1'b0;
  end
  else if (count0 == 4'b1001) begin
    count0 <= 4'b0;
    count1 <= count1 + 1;
    en <= 1'b1;
    if (count1 == 4'b1001)
      count1 <= 4'b0;
  end
  else 
    count0 <= count0 + 4'b0001;
    
    
  //STEP4
  logic[3:0]count1;
  logic en;

  ssdec s1(.in(count1), .out(ss1[6:0]), .enable(en));
 /* always_ff @ (posedge reset)
    if(reset)
      en <= 1'b0;
    else if (count0 == 4'b0)
      en <= 1'b0;
    else
      en <= 1'b1;*/
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
