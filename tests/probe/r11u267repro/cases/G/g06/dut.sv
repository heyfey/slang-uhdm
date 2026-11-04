// § genCaReplParentBoundLhs267
`define REPL(n) {n{1'b1}}
module m #(parameter int W = 4) (output logic [W-1:0] o);
  if (W > 1) begin : g
    assign o = `REPL(W);
  end
endmodule
module top(output logic [3:0] o);
  m u(.o(o));
endmodule
