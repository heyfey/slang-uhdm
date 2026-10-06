// § genLpArrRangeFirst263
module top(output logic [1:0] o [4]);
  if (1) begin : g
    parameter logic [1:0] P [4] = '{2'h0, 2'h1, 2'h2, 2'h3};
    for (genvar k = 0; k < 4; k++) begin : h
      assign o[k] = P[k];
    end
  end
endmodule
