// § genLpArrRangeFirst263
module sub #(parameter int W = 1, parameter logic [W-1:0] P = 0) (output logic [W-1:0] o);
  assign o = P;
endmodule
module top #(parameter int W = 3)(output logic [W-1:0] o);
  if (W > 1) begin : g
    localparam logic [W-1:0] V[W] = '{default: '0};
    sub #(.W(W), .P(V[0])) u (.o(o));
  end
endmodule
