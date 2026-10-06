// § genLpArrRangeFirst263
module sub #(parameter logic [7:0] V = 0) (output logic [7:0] o);
  assign o = V;
endmodule
module top(output logic [7:0] o [2], output logic [7:0] q [2]);
  for (genvar j = 0; j < 2; j++) begin : g
    localparam logic [7:0] A [2] = '{8'h11, 8'h22};
    localparam logic [7:0] B [2] = '{default: 8'h33};
    sub #(.V(A[j])) ua (.o(o[j]));
    sub #(.V(B[j])) ub (.o(q[j]));
  end
endmodule
