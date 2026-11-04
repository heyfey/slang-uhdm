// § hpLvNewClassFirstElemSpan224
package p;
  class s; endclass
  class q; s leaf; endclass
  class r; q mid; endclass
  class m;
    function void f(r rw);
      rw.mid.leaf = new;
    endfunction
  endclass
endpackage
module top; endmodule
