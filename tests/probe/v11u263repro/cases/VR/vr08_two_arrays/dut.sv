// § genLpArrRangeFirst263
module sub #(parameter logic [3:0] V = 0) (output logic [3:0] o);
  assign o = V;
endmodule
module top(output logic [3:0] o, output logic [3:0] p);
  if (1) begin : g
    localparam logic [3:0] A [2] = '{4'h1, 4'h2};
    localparam logic [3:0] B [3] = '{4'h3, 4'h4, 4'h5};
    sub #(.V(A[1])) ua (.o(o));
    sub #(.V(B[2])) ub (.o(p));
  end
endmodule
