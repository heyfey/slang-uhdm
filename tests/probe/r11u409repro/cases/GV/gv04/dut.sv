// § genGateTermGenvarFold409
module top;
  wire [4:0] c;
  wire [3:0] a;
  genvar i;
  for (i = 0; i < 2; i = i + 1) begin : g
    or g5 (c[i+1], a[i], c[i]);
  end
endmodule
