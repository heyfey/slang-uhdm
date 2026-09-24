// § netSigningTsSpan130
module top;
  for (genvar i = 0; i < 2; i++) begin : g
    wire signed [7:0] w;
    assign w = 8'd3;
  end
endmodule
