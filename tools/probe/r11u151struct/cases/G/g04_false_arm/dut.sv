// G: the condition is false: the second arm is taken.
module top(output logic [9:0] o);
  parameter int D = 1;
  localparam bit [1:0][4:0] XY = {5'b01111, 5'b10111};
  localparam bit [1:0][4:0] X = {5'b00011, 5'b00101};
  parameter bit [1:0][4:0] R = (D == 2) ? XY : X;
  assign o = R;
endmodule
