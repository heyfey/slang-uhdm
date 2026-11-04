// § hpLvNewClassFirstElemSpan224
package p;
  class s; endclass
  class r; s parent; endclass
  class b; r rw; endclass
  class m extends b;
    function void f();
      super.rw.parent = new();
    endfunction
  endclass
endpackage
module top; endmodule
