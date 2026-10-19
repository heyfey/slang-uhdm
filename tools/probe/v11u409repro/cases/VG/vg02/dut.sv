// § genGateTermGenvarFold409
module top;
  wire [7:0] a, y;
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      buf b1 (y[2*i+j], a[i*2+j]);
    end
  end
endmodule
