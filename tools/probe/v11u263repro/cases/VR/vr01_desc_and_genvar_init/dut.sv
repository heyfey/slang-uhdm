// § genLpArrRangeFirst263
module top(output logic [3:0] o, output logic [3:0] p);
  if (1) begin : g
    localparam logic [3:0] T [2:0] = '{4'h1, 4'h2, 4'h3};
    assign o = T[1];
  end
  for (genvar j = 0; j < 2; j++) begin : f
    localparam logic [3:0] U [0:1] = '{j, j + 1};
    if (j == 1) begin : h
      assign p = U[0];
    end
  end
endmodule
