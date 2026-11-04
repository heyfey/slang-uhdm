// § genCaReplParentBoundLhs267
module m #(parameter int W = 5) (input a);
  if (1) begin : g
    assign imp = {1{1'b1}};
  end
endmodule
module top;
  m u(.a(1'b0));
endmodule
