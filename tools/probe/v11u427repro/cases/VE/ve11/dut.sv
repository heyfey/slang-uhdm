// § typedLitElabAdjustLogic427
module top(output [7:0] o);
  if (1) begin : g
    localparam logic [7:0] L = 4'hA;
    assign o = L;
  end
endmodule
