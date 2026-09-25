// G: a nested ternary chain ending on a concatenation-valued parameter.
module top(output logic [9:0] o);
  parameter int D = 3;
  localparam bit [1:0][4:0] XY = {5'b01111, 5'b10111};
  localparam bit [1:0][4:0] X = {5'b00011, 5'b00101};
  localparam bit [1:0][4:0] Z = {5'b11111, 5'b00000};
  parameter bit [1:0][4:0] R = (D == 2) ? XY : (D == 3) ? Z : X;
  assign o = R;
endmodule
