// § genGateTermGenvarFold409
module top;
  wire [7:0] a, y;
  wire en;
  for (genvar i = 0; i < 3; i++) begin : g
    bufif1 b1 (y[i<<1], a[i+1], en);
    tran t1 (a[i], y[i+4]);
  end
endmodule
