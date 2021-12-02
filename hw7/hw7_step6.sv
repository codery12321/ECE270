
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
  logic [16:0] shift;
  assign {left, red, right} = shift[16:0];
  
  always_ff @(posedge reset, posedge pb[19]) begin
    if (reset==1'b1)
      shift <= 17'b1;
    else if (pb[19] == 1'b1)
      shift <= {shift[15:0], shift[16]};
  end
      
endmodule

// Add more modules down here...
