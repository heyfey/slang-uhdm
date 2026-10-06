// § genLpArrRangeFirst263
module sub #(parameter logic [3:0] V = 0) (output logic [3:0] o);
  assign o = V;
endmodule
module mid #(parameter int K = 1) (output logic [3:0] o);
  if (K > 0) begin : g
    localparam logic [3:0] T [2] = '{4'h9, 4'hA};
    sub #(.V(T[K-1])) u (.o(o));
  end
endmodule
module top(output logic [3:0] o, output logic [3:0] p);
  mid #(1) m1 (.o(o));
  mid #(2) m2 (.o(p));
endmodule
