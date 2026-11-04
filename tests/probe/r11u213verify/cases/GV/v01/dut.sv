// § genScopeClassVarListed206 (generate-if with an else branch, a different class per branch)
class ca; int x; endclass
class cb; int y; endclass
module v01 #(parameter bit SEL = 0) ();
  if (SEL) begin : ga
    ca h;
  end else begin : gb
    cb h;
    cb h2;
  end
endmodule
