// § selIdxCastTsNamedBySel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [2:0] s, output logic [1:0] o);
  child c [1:0] (.d(ck[2'(s)]), .q(o));
endmodule
