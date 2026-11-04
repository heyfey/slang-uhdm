// § hpLvNewClassFirstElemSpan224
package p;
  class s; endclass
  class r; s parent; endclass
  class m;
    r rw;
    function void f();
      this.rw.parent = new;
    endfunction
  endclass
endpackage
module top; endmodule
