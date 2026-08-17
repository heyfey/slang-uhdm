// W1 -- does the SHARED width follow OUR getRoot() DFS order when the first
// reducer is nested one level deeper than the second?  DFS visits wrap.u (N=2,
// 32 bits) before the sibling r (N=25, 400 bits).
module w1_wrap #(parameter int N = 2) ();
  rggen_or_reducer #(.WIDTH(2), .N(N)) u (.i_data(), .o_result());
endmodule
module top_w1_wrap;
  w1_wrap #(.N(2)) wrp ();
  rggen_or_reducer #(.WIDTH(2), .N(25)) r (.i_data(), .o_result());
endmodule
