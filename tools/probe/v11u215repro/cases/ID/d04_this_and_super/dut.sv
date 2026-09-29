// § incDecOperandKeepsLvalueForm215 — this. and super. paths and a plain member beside the handle form (controls)
package p;
  class base; int bc; endclass
  class seq; int n; endclass
  class sqr extends base;
    seq sp; int own;
    function void h(int x); endfunction
    function void run();
      h(this.own++);
      h(this.sp.n++);
      h(super.bc++);
      h(own++);
      h(sp.n++);
    endfunction
  endclass
endpackage
module m;
endmodule
