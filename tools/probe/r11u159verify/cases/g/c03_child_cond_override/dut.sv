// § condTakenParamRhsShared151
module sub #(parameter int D = 1)(output logic [11:0] o);
  localparam bit [1:0][1:0][2:0] XY = {{3'b011, 3'b101}, {3'b111, 3'b001}};
  localparam bit [1:0][1:0][2:0] X = {{3'b000, 3'b001}, {3'b010, 3'b100}};
  parameter bit [1:0][1:0][2:0] R = (D == 2) ? XY : X;
  assign o = R;
endmodule
module top(output logic [11:0] o1, o2);
  sub #(.D(2)) u1(.o(o1));
  sub u2(.o(o2));
endmodule
