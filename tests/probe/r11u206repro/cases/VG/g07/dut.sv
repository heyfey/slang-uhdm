// § genScopeClassVarListed206
class c;
endclass
module g07 #(parameter bit E = 1);
  if (E) begin : g
    c q;
  end else begin : n
    c r;
  end
  c m;
endmodule
