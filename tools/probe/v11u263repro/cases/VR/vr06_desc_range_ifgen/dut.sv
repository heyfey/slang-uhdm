// § genLpArrRangeFirst263
module sub #(parameter logic [3:0] V = 0) (output logic [3:0] o);
  assign o = V;
endmodule
module top(output logic [3:0] o);
  if (1) begin : g
    localparam logic [3:0] T [2:0] = '{4'h1, 4'h2, 4'h3};
    sub #(.V(T[0])) u (.o(o));
  end
endmodule
