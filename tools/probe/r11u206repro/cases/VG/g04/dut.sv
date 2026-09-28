// § genScopeClassVarListed206
class c #(type T = int);
endclass
module g04;
  if (1) begin : g
    c #(byte) q;
  end
endmodule
