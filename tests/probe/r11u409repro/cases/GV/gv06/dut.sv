// § genGateTermGenvarFold409
module top #(parameter N = 2) ();
  wire [3:0] a, y;
  genvar i;
  for (i = 0; i < N; i = i + 1) begin : g
    if (i > 0) begin : h
      buf b1 (y[i], a[i]);
    end
  end
endmodule
