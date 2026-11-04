// § genLpArrRangeFirst263
module sub #(parameter logic [7:0] P = 0) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  if (1) begin : g
    localparam logic [7:0] T[0:3] = '{8'd1, 8'd2, 8'd3, 8'd4};
    sub #(.P(T[2])) u (.o(o));
  end
endmodule
