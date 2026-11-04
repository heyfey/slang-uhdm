// § genScopeClassVarListed206 (nested generate-for, the class variable in the inner scope)
class c; int x; endclass
module v03 ();
  for (genvar i = 0; i < 2; i++) begin : go
    for (genvar j = 0; j < 2; j++) begin : gi
      c q;
    end
    c r;
  end
endmodule
