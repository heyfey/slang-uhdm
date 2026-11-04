// § modConnSelWholeLeafElab319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  wire [1:0] w = s;
  child c (.d(ck[1+w]), .q(o));
endmodule
