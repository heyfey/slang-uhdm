// § genScopeClassVarListed206
class c #(int W = 1, int V = 2);
endclass
module g01;
  if (1) begin : g
    c #(3) q;
  end
endmodule
