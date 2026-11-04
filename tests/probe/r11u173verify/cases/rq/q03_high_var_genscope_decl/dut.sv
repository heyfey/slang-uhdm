// § rangeQueryFoldUnconverted164 § rangeQueryDeclNetSize164 § rangeQueryVarDeclMask164v — $high of a variable onto a declared net inside a gen-if scope
module top();
  logic [6:2] v;
  if (1) begin : g
    wire [3:0] w;
    assign w = $high(v);
  end
endmodule
