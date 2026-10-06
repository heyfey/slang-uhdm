// § genCaReplParentBoundLhs267
program pg #(parameter int W = 4) (output wire [3:0] o);
  if (1) begin : g
    assign o = {W{1'b1}};
  end
endprogram
module top(output wire [3:0] o);
  pg u(.o(o));
endmodule
