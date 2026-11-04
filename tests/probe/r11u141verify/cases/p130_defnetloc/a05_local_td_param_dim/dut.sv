// § defNetEndOnlyLoc130
// case a05: local typedef packed array with a parameter dimension, overridden per instance
module sub #(parameter int N = 2) (output logic [4*N-1:0] o);
  typedef logic [3:0] nib_t;
  nib_t [N-1:0] x;
  assign o = x;
endmodule
module top(output logic [11:0] o);
  sub #(.N(3)) u(.o(o));
endmodule
