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
  ring8 r(.CLK(pb[1]), .S(pb[2]), .RESET(reset), .Q(right[7:5]), .X(right[4]), .Y(right[3]), .QN(right[2:0]));
endmodule

// Add more modules down here...
module ring8 (input logic CLK, S, RESET, output logic [2:0] Q, QN, output logic X, Y);
  always_ff @ (posedge CLK, posedge RESET) begin
    if (RESET == 1'b1)
      Q <= 3'b0;
    else
      Q <= QN;
  end
  always_comb begin
   if (S == 1'b1) begin
      case (Q) 
        3'b000: {X, Y, QN} = 5'b00011;
        3'b011: {X, Y, QN} = 5'b11100;
        3'b100: {X, Y, QN} = 5'b10010;
        3'b010: {X, Y, QN} = 5'b11110;
        3'b110: {X, Y, QN} = 5'b00101;
        3'b101: {X, Y, QN} = 5'b11001;
        3'b001: {X, Y, QN} = 5'b01111;
        3'b111: {X, Y, QN} = 5'b00000;
      endcase
    end
    else begin
      case (Q)
        3'b000: {X, Y, QN} = 5'b01111;
        3'b111: {X, Y, QN} = 5'b11001;
        3'b001: {X, Y, QN} = 5'b00101;
        3'b101: {X, Y, QN} = 5'b11110;
        3'b110: {X, Y, QN} = 5'b10010;
        3'b010: {X, Y, QN} = 5'b11100;
        3'b100: {X, Y, QN} = 5'b00011;
        3'b011: {X, Y, QN} = 5'b00000;
      endcase
    end
  end
endmodule

