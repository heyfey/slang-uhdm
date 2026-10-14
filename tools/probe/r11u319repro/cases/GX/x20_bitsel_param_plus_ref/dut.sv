// § modConnSelWholeLeafElab319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic a, output logic o);
  localparam int P = 1;
  child c (.d(ck[P+s]), .q(o));
endmodule
