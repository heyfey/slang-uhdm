// § hpLvNewClassFirstElemSpan224
package p;
  class s; endclass
  class r; s parent; endclass
  class m;
    function void f(r rw);
      rw.parent = new;
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class n extends m; endclass
endpackage
module top; endmodule
