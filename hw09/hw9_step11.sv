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
  redgreen rg(.CLK(pb[1]), .RESET(reset), .S(pb[2]), .R(red), .G(green), .Q(right[7:5]), .QN(right[2:0]));
endmodule

// Add more modules down here...
module redgreen (input logic CLK, RESET, S, output logic R, G, output logic [2:0] Q, QN);
  always_ff @ (posedge CLK, posedge RESET) begin
    if (RESET == 1'b1)
      Q <= 3'b0;
    else
      Q <= QN;
  end
  always_comb begin
    if (S == 1'b1) begin
      case (Q) 
        3'b000: {R, G, QN} = 5'b00010;
        3'b010: {R, G, QN} = 5'b00111;
        3'b111: {R, G, QN} = 5'b10111;
        3'b101: {R, G, QN} = 5'b00100;
        3'b100: {R, G, QN} = 5'b00010;
        3'b110: {R, G, QN} = 5'b01110;
        default: {R, G, QN} = 5'b00000;
      endcase
    end
    else begin
      case (Q)
        3'b000: {R, G, QN} = 5'b00000;
        3'b010: {R, G, QN} = 5'b00101;
        3'b101: {R, G, QN} = 5'b00111;
        3'b111: {R, G, QN} = 5'b10111;
        3'b100: {R, G, QN} = 5'b00110;
        3'b110: {R, G, QN} = 5'b01110;
        default: {R, G, QN} = 5'b00000;
      endcase
    end
  end
endmodule
