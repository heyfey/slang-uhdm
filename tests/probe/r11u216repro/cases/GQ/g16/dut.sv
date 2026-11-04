// § genScopeRangeQueryFold216 — $high onto a module output narrower than the value (the mask), and a select target (control)
module top(input logic [13:2] i, output logic [1:0] o, output logic [3:0] p);
  if (1) begin : g
    assign o = $high(i);
    assign p[1:0] = $low(i);
  end
endmodule
