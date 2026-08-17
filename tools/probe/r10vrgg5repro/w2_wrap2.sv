// W2 -- the mirror of W1: the N=25 reducer is the SIBLING that comes FIRST in
// source order, the N=2 one is nested in the wrapper declared SECOND.
module w2_wrap2 #(parameter int N = 2) ();
  rggen_or_reducer #(.WIDTH(2), .N(N)) u (.i_data(), .o_result());
endmodule
module top_w2_wrap2;
  rggen_or_reducer #(.WIDTH(2), .N(25)) r (.i_data(), .o_result());
  w2_wrap2 #(.N(2)) wrp ();
endmodule
