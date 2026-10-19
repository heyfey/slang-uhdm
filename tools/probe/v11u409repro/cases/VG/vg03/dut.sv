// § genGateTermGenvarFold409
module top;
  wire [7:0] a, y;
  for (genvar i = 0; i < 4; i++) begin : g
    if (i % 2 == 0) begin : e
      not n1 (y[i], a[i/2]);
    end
  end
endmodule
