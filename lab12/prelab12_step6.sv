
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
  addsub8 as1(.a(pb[7:0]), .b(pb[15:8]), .op(pb[18]), .s(right[7:0]), .co(red));
endmodule

// Add more modules down here...
module addsub8 (input logic [7:0] a, b, input logic op, output logic [7:0] s, output logic co);
  logic [7:0]op1;
  assign op1 = {op, op, op, op, op, op, op, op};
  cla8 cl1(.a(a), .b(b ^ op1), .ci(op), .s(s), .co(co));
endmodule

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

module ha (input logic a, b, output logic s, co);
  assign s = a ^ b;
  assign co = a & b;
endmodule