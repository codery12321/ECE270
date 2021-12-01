//STEP 1
module ha (input logic a, b, output logic s, co);
  assign s = a ^ b;
  assign co = a & b;
endmodule

//STEP 2
module faha (input logic a, b, ci, output logic s, co);

  logic h1_s, h2_s, h1_co, h2_co;

  ha h1(.a(a), .b(b), .s(h1_s), .co(h1_co));
  ha h2(.a(ci), .b(h1_s), .s(h2_s), .co(h2_co));
  assign s = h2_s;
  assign co = h1_co | h2_co;

endmodule

//STEP 3
module fa (input logic a, b, ci, output logic s, co);
  assign s = a ^ b ^ ci;
  assign co = a &b | a&ci | b&ci;
endmodule

//STEP 4
module fa4(input logic [3:0]a, b, input logic ci, output logic [3:0] s, output logic co);
  logic co1, co2, co3;

  fa f1(.a(a[0]), .b(b[0]), .ci(ci), .s(s[0]), .co(co1));
  fa f2(.a(a[1]), .b(b[1]), .ci(co1), .s(s[1]), .co(co2));
  fa f3(.a(a[2]), .b(b[2]), .ci(co2), .s(s[2]), .co(co3));
  fa f4(.a(a[3]), .b(b[3]), .ci(co3), .s(s[3]), .co(co));
endmodule

//STEP 5
module cla8 (input logic [7:0] a, b, input logic ci, output logic [7:0]s, output logic co);
  logic [7:0]P, G, C;
  assign co = C[7];

  ha h0(.a(a[0]), .b(b[0]), .s(P[0]), .co(G[0]));
  ha h1(.a(a[1]), .b(b[1]), .s(P[1]), .co(G[1]));
  ha h2(.a(a[2]), .b(b[2]), .s(P[2]), .co(G[2]));
  ha h3(.a(a[3]), .b(b[3]), .s(P[3]), .co(G[3]));
  ha h4(.a(a[4]), .b(b[4]), .s(P[4]), .co(G[4]));
  ha h5(.a(a[5]), .b(b[5]), .s(P[5]), .co(G[5]));
  ha h6(.a(a[6]), .b(b[6]), .s(P[6]), .co(G[6]));
  ha h7(.a(a[7]), .b(b[7]), .s(P[7]), .co(G[7]));

  assign C[0] = G[0] | ci  & P[0];
  assign C[1] = G[1] | G[0] & P[1] | ci  & &P[1:0];
  assign C[2] = G[2] | G[1] & P[2] | G[0] & &P[2:1] | ci  & &P[2:0];
  assign C[3] = G[3] | G[2] & P[3] | G[1] & &P[3:2] | G[0] & &P[3:1] | ci  & &P[3:0];
  assign C[4] = G[4] | G[3] & P[4] | G[2] & &P[4:3] | G[1] & &P[4:2] | G[0] & &P[4:1] | ci & &P[4:0];
  assign C[5] = G[5] | G[4] & P[5] | G[3] & &P[5:4] | G[2] & &P[5:3] | G[1] & &P[5:2] | G[0] & &P[5:1] | ci & &P[5:0];
  assign C[6] = G[6] | G[5] & P[6] | G[4] & &P[6:5] | G[3] & &P[6:4] | G[2] & &P[6:3] | G[1] & &P[6:2] | G[0] & &P[6:1] | ci & &P[6:0];
  assign C[7] = G[7] | G[6] & P[7] | G[5] & &P[7:6] | G[4] & &P[7:5] | G[3] & &P[7:4] | G[2] & &P[7:3] | G[1] & &P[7:2] | G[0] & &P[7:1] | ci & &P[7:0];

  assign s[0] = ci ^ P[0];
  assign s[7:1] = C[6:0] ^ P[7:1];
endmodule

//STEP 6
module addsub8 (input logic [7:0] a, b, input logic op, output logic [7:0] s, output logic co);
  logic [7:0]op1;
  assign op1 = {op, op, op, op, op, op, op, op};
  cla8 cl1(.a(a), .b(b ^ op1), .ci(op), .s(s), .co(co));
endmodule

//STEP 7
module bcdadd1 (input logic [3:0]a, b, input logic ci, output logic co, output logic [3:0]s);
  logic [3:0]z, bNew;
  logic cout;
  fa4 f1(.a(a), .b(b), .ci(ci), .s(z), .co(cout));
  assign co = cout | z[3] & z[2] | z[3] & z[1];
  assign bNew = {1'b0, co, co, 1'b0};
  fa4 add(.a(bNew), .b(z), .ci(1'b0), .s(s), .co());
endmodule

//STEP 8
module bcdadd4 (input logic [15:0] a, b, input logic ci, output logic co,output logic [15:0]s);
  logic co1, co2, co3;

  bcdadd1 ba1(.a(a[ 3: 0]), .b(b[ 3: 0]), .ci(ci ), .co(co1), .s(s[ 3: 0]));
  bcdadd1 ba2(.a(a[ 7: 4]), .b(b[ 7: 4]), .ci(co1), .co(co2), .s(s[ 7: 4]));
  bcdadd1 ba3(.a(a[11: 8]), .b(b[11: 8]), .ci(co2), .co(co3), .s(s[11: 8]));
  bcdadd1 ba4(.a(a[15:12]), .b(b[15:12]), .ci(co3), .co(co ), .s(s[15:12]));
endmodule

//STEP 9
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

//STEP10
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
