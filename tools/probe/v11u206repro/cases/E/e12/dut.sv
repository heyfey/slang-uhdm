// § genScopeClassVarListed206
class c;
endclass
module sub;
  if (1) begin : g
    c q;
  end
endmodule
module e12;
  sub u1 ();
  sub u2 ();
endmodule
