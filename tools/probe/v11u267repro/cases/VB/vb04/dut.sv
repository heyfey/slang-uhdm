// § genCaReplParentBoundLhs267
module m #(parameter int W = 2, parameter int D = 1) (output wire [3:0] o);
  if (W > 1) begin : g
    assign #D o = {W{2'b10}};
  end
endmodule
module top(output wire [3:0] o);
  m u(.o(o));
endmodule
