// § genScopeClassVarListed206
class c #(type T = int);
endclass
module e11;
  if (1) begin : g
    c #(logic [3:0]) q;
    c #() r;
  end
endmodule
