// § newLhsVarSelNameSpan437
class C; int v; endclass
class D;
  function void f(); C c[2][2]; c[1][0] = new; endfunction
endclass
module top; D d; initial begin d = new; d.f(); end endmodule
