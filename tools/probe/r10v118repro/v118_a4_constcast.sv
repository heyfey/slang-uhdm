// r10v118 arm C — the ONE spelling whose slang syntax kind is
// SignedCastExpression while the conversion's TYPE is `string`:  const'(...).
// Legal SV (IEEE 1800 6.24.1 const cast).  Surelog DOES mint a vpiCastOp for it.
module Girth42;
  string Placard;
  initial begin
    Placard = "orig";
    Placard = {Placard, const'(Placard), "!"};
  end
endmodule
