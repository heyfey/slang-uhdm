// § modConnVarSelWholeNames319
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  function automatic logic [1:0] f(input logic [1:0] x); return x; endfunction
  child c (.d(m[f(s)][t]), .q(o));
endmodule
