// § sysCallInIdxNamedBySel319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module tgt (input logic [3:0] ck, input logic [1:0] s, output logic o);
  assign o = ck[0];
endmodule
bind tgt child cb (.d(ck[$signed(s)]), .q());
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  tgt t0 (.ck(ck), .s(s), .o(o));
endmodule
