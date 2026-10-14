// § sysCallInIdxNamedBySel319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module mid (input logic [3:0] ck, input logic [1:0] s, output logic o);
  child c (.d(ck[$signed(s)]), .q(o));
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  logic o2;
  mid u1 (.ck(ck), .s(s), .o(o));
  mid u2 (.ck(ck), .s(t), .o(o2));
endmodule
