// § tfItemLocalSpecAtName209 — r11u217 l04: a paren-less package function declaring a local of a SPECIALIZATION of a generic class of the same package, with and without an initializer, and with a type argument
package p;
  class g #(type T = int, int N = 1);
    T v;
    static function g#(T, N) mk(); return null; endfunction
  endclass
  class c;
    extern function void f;
  endclass
  function void c::f;
    g#(byte, 2) a = g#(byte, 2)::mk();
    g#(int) b;
    g #( .N(3) ) e = null;
    if (a == null) b = null;
  endfunction
endpackage
module top;
  p::c h;
endmodule
