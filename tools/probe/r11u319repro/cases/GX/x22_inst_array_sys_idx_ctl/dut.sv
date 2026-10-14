// § sysCallInIdxNamedBySel319
module child (input logic d);
endmodule
module top (input logic [3:0] ck, input logic [1:0] s, input logic a, output logic o);
  child c [2] (.d(ck[$signed(s)] | a));
  assign o = a;
endmodule
