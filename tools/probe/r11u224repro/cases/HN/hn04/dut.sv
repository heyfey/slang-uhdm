// r11u224 decode: an lvalue path assigned a class new
package p;
  class r; int d[]; endclass
  class m;
    function void f(r rw);
      rw.d = new[3];
    endfunction
  endclass
endpackage
module top; endmodule
