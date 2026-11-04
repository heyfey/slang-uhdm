// § hpLvNewClassFirstElemSpan224
package p;
  class s; int x; endclass
  class r; s parent; endclass
  class m;
    function void f(r rw, s src);
      rw.parent = new src;
    endfunction
  endclass
endpackage
module top; endmodule
