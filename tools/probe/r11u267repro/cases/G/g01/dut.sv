// § genCaReplParentBoundLhs267
module m #(parameter int W = 5) (output logic [W-1:0] o);
  if (1) begin : g
    logic [W-1:0] loc;
    assign loc = {W{1'b1}};
    assign o = loc;
  end
endmodule
module top(output logic [4:0] o);
  m u(.o(o));
endmodule
