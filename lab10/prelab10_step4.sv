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
  logic state;
  simonctl sctl (.clk(pb[0]), .rst(reset), .lvlmax(pb[16]), .win(pb[17]), .lose(pb[18]), .state(state));
  assign right[0] = state;  
endmodule

// Add more modules down here...
module simonctl(input logic clk, rst, lvlmax, win, lose, output logic state);
  logic next_state;
  typedef enum logic { RDY, ENT } simonstate_t; //defines the states RDY and ENT for us as 0 and 1
  
  //asynchronously reset state to RDY when a rising edge rst occurs
    //otherwise to set state to a new logic signal named next_state.
  always_ff @ (posedge clk, posedge rst) begin
    if (rst == 1'b1)
      state <= RDY;
    else
      state <= next_state;
  end
  
  always_comb begin
    if (lose | (~lvlmax & win))
      next_state = RDY;
    else if (~lvlmax)
      next_state =  ENT;
      
    else
    next_state = state;
  end
  
endmodule
