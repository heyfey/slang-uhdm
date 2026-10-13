// § selIdxCastTsNamedBySel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top #(parameter int P = 5) (input logic [3:0] ck, output logic o);
  child c (.d(ck[2'(P)]), .q(o));
endmodule
