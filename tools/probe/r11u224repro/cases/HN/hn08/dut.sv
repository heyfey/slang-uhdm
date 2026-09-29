// r11u224 decode: an lvalue path assigned a class new
package p;
  class s; endclass
  class r; s parent; endclass
  class m;
    function void f(r rw, s x);
      rw.parent = x == null ? new : x;
    endfunction
  endclass
endpackage
module top; endmodule
