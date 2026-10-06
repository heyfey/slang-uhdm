// § genLpArrRangeFirst263
module sub #(parameter bit [1:0] P = 0) (output logic [1:0] o);
  assign o = P;
endmodule
module top(output logic [1:0] o);
  localparam bit [1:0] M[4] = '{2'h0, 2'h1, 2'h2, 2'h3};
  sub #(.P(M[1])) u (.o(o));
endmodule
