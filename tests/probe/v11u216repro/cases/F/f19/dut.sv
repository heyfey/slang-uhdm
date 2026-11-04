// § genScopeRangeQueryFold216 — a query two generate levels deep on a module port and on a net declared in the outer block
module top (input logic [9:4] i, output logic [7:0] c, output logic [7:0] d);
  for (genvar k = 0; k < 1; k++) begin : g
    logic [3:1] h;
    if (1) begin : n
      assign c = $low(i);
      assign d = $left(h);
    end
  end
endmodule
