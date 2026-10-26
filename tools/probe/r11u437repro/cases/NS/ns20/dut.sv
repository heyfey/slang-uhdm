// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
class K;
  C c[2];
  covergroup cg; coverpoint c[0].v; endgroup
  function void f(); c[0] = new; c[1] = new c[0]; endfunction
endclass
module top; K k; initial begin k = new; k.f(); end endmodule
