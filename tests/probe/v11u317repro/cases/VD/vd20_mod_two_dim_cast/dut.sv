// § selIdxCastTsNamedBySel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic [2:0] s, output logic o);
  child c (.d(m[1'(s)][0]), .q(o));
endmodule
