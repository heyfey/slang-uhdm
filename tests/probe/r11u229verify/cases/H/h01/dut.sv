// § hpLvNewClassFirstElemSpan224 (the lvalue path written over two lines)
package p;
  class s; endclass
  class r; s parent; endclass
  class t;
    r rw;
    function void f();
      rw = new;
      rw
        .parent = new;
    endfunction
  endclass
endpackage
module top; endmodule
