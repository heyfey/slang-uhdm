// § modConnVarSelWholeNames319
module child (input logic d);
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic a, output logic o);
  child c [2] (.d(m[s][1]));
  assign o = a;
endmodule
