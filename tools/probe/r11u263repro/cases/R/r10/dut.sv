// § genLpArrRangeFirst263
module sub #(parameter bit [1:0] P = 0) (output logic [1:0] o);
  assign o = P;
endmodule
module top(output logic [1:0] o);
  if (1) begin : g
    localparam bit [1:0] IV[4] = '{2'h0, 2'h1, 2'h2, 2'h3};
  end
  sub #(.P(2'h1)) u (.o(o));
endmodule
