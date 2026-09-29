// § hpLvNewClassFirstElemSpan224
package p;
  class s; endclass
  class r; s parent; endclass
  class m;
    function void f();
      automatic r rw = new;
      rw . parent = new;
    endfunction
  endclass
endpackage
module top; endmodule
