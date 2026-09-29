// § hpLvNewClassFirstElemSpan224
package p;
  class s; int x; endclass
  class d extends s; endclass
  class r; s parent; endclass
  class m;
    function void f(r rw);
      rw.parent = d::new;
    endfunction
  endclass
endpackage
module top; endmodule
