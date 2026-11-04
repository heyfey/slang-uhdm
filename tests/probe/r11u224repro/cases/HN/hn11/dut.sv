// § hpLvNewClassFirstElemSpan224
package p;
  class s; function new(int a, int b); endfunction endclass
  class r; s parent; endclass
  class m;
    function void f(r rw);
      rw.parent = new(1,
                      2);
    endfunction
  endclass
endpackage
module top; endmodule
