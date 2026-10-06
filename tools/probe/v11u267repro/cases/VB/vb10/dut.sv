// § genCaReplParentBoundLhs267
module m #(parameter int W = 4) (output wire [3:0] o, output wire [3:0] p);
  if (1) begin : g
    assign o = {W{1'b1}};
  end else begin : h
    assign o = '0;
  end
  for (genvar i = 0; i < 2; i++) begin : f
    if (i == 1) begin : k
      assign p = {W{1'b0}};
    end
  end
endmodule
module top(output wire [3:0] o, output wire [3:0] p, output wire [3:0] o2, output wire [3:0] p2);
  m u(.o(o), .p(p));
  m u2(.o(o2), .p(p2));
endmodule
