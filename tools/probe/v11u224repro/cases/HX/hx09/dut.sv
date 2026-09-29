// § hpLvNewClassFirstElemSpan224
package p;
  class s; endclass
  class r; s parent; endclass
  class q; r rr; endclass
  class m;
    q qq;
    function void f();
      qq.rr.parent = new;  qq.rr = new;
    endfunction
  endclass
endpackage
module top; endmodule
