// G: two ternary parameters take the same nested concatenation.
module top(output logic [11:0] o, output logic [11:0] p);
  parameter int D = 2;
  localparam bit [1:0][1:0][2:0] XY = {{3'b011, 3'b101}, {3'b111, 3'b001}};
  localparam bit [1:0][1:0][2:0] X = {{3'b000, 3'b001}, {3'b010, 3'b100}};
  parameter bit [1:0][1:0][2:0] R = (D == 2) ? XY : X;
  parameter bit [1:0][1:0][2:0] S = (D != 2) ? X : XY;
  assign o = R;
  assign p = S;
endmodule
