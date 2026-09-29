// § hpLvNewClassFirstElemSpan224
`define DO(x) x
package p;
  class s; endclass
  class r; s parent; endclass
  class m;
    function void f(r rw);
      `DO(rw.parent = new;)
    endfunction
  endclass
endpackage
module top; endmodule
