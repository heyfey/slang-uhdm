// vb32s1 — SHADOWING: a LOCAL subroutine and a LOCAL variable whose name is
// the final identifier, plus deeper inheritance chains, plus a `this_type`
// typedef pointing at the BASE.
package s32;
  class b32;
    static int h32;
    extern static function int f32(int a);
    extern static function int g32(int a);
  endclass
  function int b32::f32(int a); h32 += a; return a; endfunction
  function int b32::g32(int a); return a; endfunction

  class m32 extends b32;
    typedef b32 base_t32;      // typedef naming the BASE class
    typedef m32 this_type;
    extern static function int f32(int a);   // OVERRIDE, out-of-body in m32
  endclass
  function int m32::f32(int a); return a + 1; endfunction

  class d32 extends m32;
    typedef d32 this_type;
    extern static function int run32();
  endclass
  function int d32::run32();
    int f32;                    // a LOCAL variable shadowing the method name
    int r;
    r  = d32::f32(1);           // X1  derived name, callee out-of-body in m32 -> ref
    r += m32::f32(2);           // X2  defining class name                     -> call
    r += b32::f32(3);           // X3  the grandparent's own                   -> call
    r += d32::g32(4);           // X4  derived name, callee out-of-body in b32 -> ref
    r += base_t32::f32(5);      // X5  typedef of the base                     -> ref
    r += this_type::f32(6);     // X6                                          -> ref
    f32 = r;
    return f32;
  endfunction
endpackage

module vb32s1;
  int r;
  initial r = s32::d32::run32();
endmodule
