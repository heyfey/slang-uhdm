// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
class D;
  C c[2];
  function void f(); this.c[1] = new this.c[0]; endfunction
endclass
module top; D d; initial begin d = new; d.f(); end endmodule
