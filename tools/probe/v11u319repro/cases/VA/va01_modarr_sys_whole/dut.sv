// § sysCallInIdxNamedBySel319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  logic [1:0] q2;
  child c [1:0] (.d(ck[$signed(s)]), .q(q2));
  assign o = q2[0];
endmodule
