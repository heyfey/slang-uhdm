// § genLpArrRangeFirst263
module sub #(parameter logic [3:0] V = 0) (output logic [3:0] o);
  assign o = V;
endmodule
module top(output logic [3:0] o [2][2]);
  for (genvar i = 0; i < 2; i++) begin : a
    for (genvar j = 0; j < 2; j++) begin : b
      localparam logic [3:0] X [0:3] = '{4'h4, 4'h5, 4'h6, 4'h7};
      sub #(.V(X[i+j])) u (.o(o[i][j]));
    end
  end
endmodule
