// § deferredPortElemImplicitEnd231 — control: a packed range of localparams only (not deferred)
module arb #(parameter int N = 4) (
  input [7:0]    data_i [N],
  output [3:0] o
);
  assign o = data_i[0][3:0];
endmodule
module top(input [7:0] d [4], output [3:0] g);
  arb #(.N(4)) u (.data_i(d), .o(g));
endmodule
