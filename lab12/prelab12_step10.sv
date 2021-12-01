
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
  logic [15:0] s;
  bcdaddsub4 bas4(.a(16'h0000), .b(16'h0001), .op(1), .s(s));
  ssdec s0(.in(s[3:0]),   .out(ss0[6:0]), .enable(1));
  ssdec s1(.in(s[7:4]),   .out(ss1[6:0]), .enable(1));
  ssdec s2(.in(s[11:8]),  .out(ss2[6:0]), .enable(1));
  ssdec s3(.in(s[15:12]), .out(ss3[6:0]), .enable(1));
endmodule

// Add more modules down here...
module bcdaddsub4 (input logic [15:0] a, b, input logic op, output logic [15:0]s);
  logic [3:0]out1, out2, out3, out4;
  logic [15:0]cin, bNew;
  bcd9comp1 cmp1(.in(b[3:0]), .out(out1));
  bcd9comp1 cmp2(.in(b[7:4]), .out(out2));
  bcd9comp1 cmp3(.in(b[11:8]), .out(out3));
  bcd9comp1 cmp4(.in(b[15:12]), .out(out4));
  assign cin = {out4, out3, out2, out1};
  assign bNew = op == 1 ? cin : b;
  bcdadd4 ba1(.a(a), .b(bNew), .ci(op), .co(), .s(s));
endmodule

module bcd9comp1(input logic [3:0]in, output logic [3:0]out);
  always_comb
    case(in)
      4'b0000: out = 4'b1001;
      4'b0001: out = 4'b1000;
      4'b0010: out = 4'b0111;
      4'b0011: out = 4'b0110;
      4'b0100: out = 4'b0101;
      4'b0101: out = 4'b0100;
      4'b0110: out = 4'b0011;
      4'b0111: out = 4'b0010;
      4'b1000: out = 4'b0001;
      4'b1001: out = 4'b0000;
      default: out = 4'b0000; 
    endcase
endmodule

module bcdadd4 (input logic [15:0] a, b, input logic ci, output logic co,output logic [15:0]s);
  logic co0, co1, co2, co3;

  bcdadd1 ba1(.a(a[ 3: 0]), .b(b[ 3: 0]), .ci(ci ), .co(co1), .s(s[ 3: 0]));
  bcdadd1 ba2(.a(a[ 7: 4]), .b(b[ 7: 4]), .ci(co1), .co(co2), .s(s[ 7: 4]));
  bcdadd1 ba3(.a(a[11: 8]), .b(b[11: 8]), .ci(co2), .co(co3), .s(s[11: 8]));
  bcdadd1 ba4(.a(a[15:12]), .b(b[15:12]), .ci(co3), .co(co ), .s(s[15:12]));
endmodule

module bcdadd1 (input logic [3:0]a, b, input logic ci, output logic co, output logic [3:0]s); 
  logic [3:0]z, bNew;
  logic cout;
  fa4 f1(.a(a), .b(b), .ci(ci), .s(z), .co(cout));
  assign co = cout | z[3] & z[2] | z[3] & z[1];
  assign bNew = {1'b0, co, co, 1'b0};
  fa4 add(.a(bNew), .b(z), .ci(1'b0), .s(s), .co());
endmodule

module fa4(input logic [3:0]a, b, input logic ci, output logic [3:0] s, output logic co);
  logic co0, co1, co2, co3;

  fa f1(.a(a[0]), .b(b[0]), .ci(ci), .s(s[0]), .co(co1));
  fa f2(.a(a[1]), .b(b[1]), .ci(co1), .s(s[1]), .co(co2));
  fa f3(.a(a[2]), .b(b[2]), .ci(co2), .s(s[2]), .co(co3));
  fa f4(.a(a[3]), .b(b[3]), .ci(co3), .s(s[3]), .co(co));
endmodule

module fa (input logic a, b, ci, output logic s, co);
  assign s = a ^ b ^ ci;
  assign co = a &b | a&ci | b&ci;
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