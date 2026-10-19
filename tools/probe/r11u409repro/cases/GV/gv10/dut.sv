// § genGateTermGenvarFold409
module top;
  wire [3:0] a, y;
  genvar i;
  for (i = 0; i < 2; i = i + 1) begin : g
    tran t1 (y[i], a[i]);
    bufif1 b2 (y[i+2], a[i], a[i+2]);
  end
endmodule
