// § hpLvNewClassFirstElemSpan224 (the handle a class specialization)
package p;
  class s; endclass
  class r #(int W = 1); s parent; endclass
  class t;
    r #(4) rw;
    function void f();
      rw = new;
      rw.parent = new;
    endfunction
  endclass
endpackage
module top; endmodule
