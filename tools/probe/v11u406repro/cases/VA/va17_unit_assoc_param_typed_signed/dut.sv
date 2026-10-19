// § assocIdxParamBoundTs406
parameter logic signed [7:0] S = 3;
typedef int a_t [logic [S:0]];
module top;
  a_t v;
endmodule
