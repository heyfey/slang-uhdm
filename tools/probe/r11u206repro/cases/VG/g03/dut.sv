// § genScopeClassVarListed206
class c #(type T = int);
endclass
module g03;
  for (genvar i = 0; i < 2; i++) begin : g
    c #(byte) q;
  end
endmodule
