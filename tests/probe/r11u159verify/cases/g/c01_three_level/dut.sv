// § condTakenParamRhsShared151
module top(output logic [11:0] o);
  parameter int D = 3;
  localparam bit [1:0][1:0][2:0] XY = {{3'b011, 3'b101}, {3'b111, 3'b001}};
  localparam bit [1:0][1:0][2:0] X = {{3'b000, 3'b001}, {3'b010, 3'b100}};
  localparam bit [1:0][1:0][2:0] Z = {{3'b110, 3'b110}, {3'b010, 3'b000}};
  parameter bit [1:0][1:0][2:0] R = (D == 1) ? X : (D == 2) ? XY : Z;
  assign o = R;
endmodule
