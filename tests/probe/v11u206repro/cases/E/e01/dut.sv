// § genScopeClassVarListed206
class c;
  int x;
endclass
module e01 (input logic clk, output int o);
  if (1) begin : g
    c q;
    initial begin
      q = new;
      q.x = 3;
    end
  end
  assign o = 0;
endmodule
