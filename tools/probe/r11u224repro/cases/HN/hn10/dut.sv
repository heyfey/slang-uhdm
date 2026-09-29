// § hpLvNewClassFirstElemSpan224
`define MKNEW(h) h.parent = new;
package p;
  class s; endclass
  class r; s parent; endclass
  class m;
    function void f(r rw);
      `MKNEW(rw)
    endfunction
  endclass
endpackage
module top; endmodule
