// § selIdxCastTsNamedBySel317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module tgt (input logic [3:0] ck, input logic [2:0] s, output logic o);
  assign o = ck[0];
endmodule
module top (input logic [3:0] ck, input logic [2:0] s, output logic o);
  tgt t (.ck(ck), .s(s), .o(o));
endmodule
bind tgt child cb (.d(ck[2'(s)]), .q());
