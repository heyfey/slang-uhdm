// § genScopeClassVarListed206
class c;
endclass
module e10;
  c top_q;
  if (1) begin : g
    c q;
  end
  if (0) begin : h
    c r;
  end else begin : k
    c s;
  end
endmodule
