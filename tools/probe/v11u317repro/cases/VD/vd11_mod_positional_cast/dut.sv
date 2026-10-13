// § selIdxCastTsNamedBySel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [2:0] s, output logic o);
  child c (ck[2'(s)], o);
endmodule
