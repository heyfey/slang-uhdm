// § modConnSelWholeLeafElab319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  logic o2;
  child c1 (.d(ck[1+s]), .q(o));
  child c2 (.d(ck[t+s]), .q(o2));
endmodule
