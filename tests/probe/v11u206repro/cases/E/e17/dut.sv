// § genScopeClassVarListed206
class c;
endclass
module e17 (input logic clk, output logic o);
  if (1) begin : g
    c q;
    always @(posedge clk) if (q == null) q = new;
  end
  assign o = 1'b0;
endmodule
