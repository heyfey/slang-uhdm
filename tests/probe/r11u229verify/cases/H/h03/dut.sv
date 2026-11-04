// § hpLvNewClassFirstElemSpan224 (the constructor argument reads the lvalue)
package p;
  class s; s prev; function new(s x = null); prev = x; endfunction endclass
  class r; s parent; endclass
  class t;
    r rw;
    function void f();
      rw = new;
      rw.parent = new(rw.parent);
    endfunction
  endclass
endpackage
module top; endmodule
