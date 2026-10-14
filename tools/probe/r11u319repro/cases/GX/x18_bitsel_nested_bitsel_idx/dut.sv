// § modConnSelWholeLeafElab319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [1:0] k [2], input logic s, output logic o);
  child c (.d(ck[k[s]]), .q(o));
endmodule
