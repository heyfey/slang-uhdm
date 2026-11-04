// § genScopeClassVarListed206
class c;
endclass
module sub;
  if (1) begin : g
    c q;
  end
endmodule
module e19;
  for (genvar i = 0; i < 2; i++) begin : l
    sub u ();
  end
endmodule
