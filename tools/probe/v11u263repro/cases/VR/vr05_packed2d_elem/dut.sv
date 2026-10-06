// § genLpArrRangeFirst263
module top(output logic [1:0][3:0] o);
  if (1) begin : g
    localparam logic [1:0][3:0] T [2] = '{8'h12, 8'h34};
    assign o = T[0];
  end
endmodule
