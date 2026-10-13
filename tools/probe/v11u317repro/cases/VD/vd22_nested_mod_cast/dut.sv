// § selIdxCastTsNamedBySel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module mid (input logic [3:0] ck, input logic [2:0] s, output logic o);
  child c (.d(ck[2'(s)]), .q(o));
endmodule
module top (input logic [3:0] ck, input logic [2:0] s, output logic [1:0] o);
  mid m0 (.ck(ck), .s(s), .o(o[0]));
  mid m1 (.ck(ck), .s(s), .o(o[1]));
endmodule
