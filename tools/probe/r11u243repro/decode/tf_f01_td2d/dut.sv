// § fixedClassPropIsArrayVar6 (decode of its residue R1, a typedef-named unpacked-array class property; not written by r11u243)
// a class property typed by a typedef'd two-dimensional fixed unpacked array
package p;
  typedef int f2_t[2][3];
  class fac;
    f2_t m_f;
    function int go(); return m_f[0][1]; endfunction
  endclass
endpackage
module top;
  import p::*;
  int x;
  initial begin fac f = new; x = f.go(); end
endmodule
