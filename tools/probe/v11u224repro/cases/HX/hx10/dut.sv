// § hpLvNewClassFirstElemSpan224
package p;
  class s; endclass
  class r; s parent; static r inst; endclass
  class m;
    function void f();
      r::inst.parent = new;
    endfunction
  endclass
endpackage
module top; endmodule
