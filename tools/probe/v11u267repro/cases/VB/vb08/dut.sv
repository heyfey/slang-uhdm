// § genCaReplParentBoundLhs267
module m #(parameter int W = 4) (output wire [3:0] o, output wire [3:0] p);
  wire [3:0] n;
  if (1) begin : g
    assign n = {W{1'b1}};
    assign p = {W{1'b0}} | n;
  end
  assign o = n;
endmodule
module top(output wire [3:0] o, output wire [3:0] p);
  m u(.o(o), .p(p));
endmodule
