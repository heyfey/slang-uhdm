// § genLpArrRangeFirst263
module sub #(parameter int P = 0) (output logic [3:0] o);
  assign o = P;
endmodule
module top(output logic [3:0] o[2]);
  for (genvar i = 0; i < 2; i++) begin : g
    localparam int K[3] = '{1, 2, 3};
    sub #(.P(K[i])) u (.o(o[i]));
  end
endmodule
