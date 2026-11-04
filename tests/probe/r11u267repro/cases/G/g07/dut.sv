// § genCaReplParentBoundLhs267
module m #(parameter int W = 4) (output logic [W-1:0] o);
  if (1) begin : g
    assign o = {W{1'b1}};
  end
endmodule
module top(output logic [3:0] o);
  m u(.o(o));
endmodule
