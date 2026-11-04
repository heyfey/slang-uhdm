// § hpLvNewClassFirstElemSpan224
package p;
  class s; int x; function new(int a = 0, int b = 1); x = a + b; endfunction endclass
  class r; s parent; endclass
  function automatic void f(r rw);
    rw.parent = new(.b(2), .a(3));
  endfunction
endpackage
module top; endmodule
