// § rqParamOpBoundAtCall216v (with § ndaRangeQueryFold216) — a ranged parameter with arithmetic bounds (W-1, 2*W) in net initializers, the child twice
module sub #(parameter int W = 2, parameter logic [W-1:0] P = 1, parameter logic [0:2*W] Q = 1) (output logic [7:0] o, o2);
  wire [7:0] w = $high(P);
  wire [7:0] x = $right(Q);
  assign o = w;
  assign o2 = x;
endmodule
module top (output logic [7:0] a1, a2, b1, b2);
  sub #(.W(3)) a (.o(a1), .o2(a2));
  sub #(.W(5)) b (.o(b1), .o2(b2));
endmodule
