// § genLpArrRangeFirst263
module m #(parameter int W = 2) (output logic [W-1:0] o [2]);
  if (W > 1) begin : g
    localparam logic [W-1:0] T [2] = '{1, 2};
    assign o = T;
  end
endmodule
module top(output logic [1:0] a [2], output logic [2:0] b [2]);
  m #(2) u2 (.o(a));
  m #(3) u3 (.o(b));
endmodule
