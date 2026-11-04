// § selIdxCastTsNamedBySel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [1:0] s, output logic o);
  child c (.d(ck[signed'(s)]), .q(o));
endmodule
