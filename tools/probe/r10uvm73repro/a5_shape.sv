// r10uvm73 arm a5 — THE SHAPE AXIS: which of the class-property EMISSION ARMS
// the degradation reaches.  a1's array cells (`holder::e_t x[3]`) already agree
// on both sides, so the ARRAY arm is out of scope by measurement; this arm asks
// the harder question — a class-scope typedef of a WHOLE ARRAY / QUEUE /
// UNPACKED STRUCT, which lands in the SCALAR arm because the property's own
// type IS a typedef name — plus the NON-class scopes as controls.
package p1;
  class holder;
    typedef enum {H_A, H_B} e_t;
    typedef int    arr_t[4];                // whole-array typedef
    typedef int    q_t[$];                  // queue typedef
    typedef struct { int a; int b; } st_t;  // UNPACKED struct typedef
    typedef struct packed { bit [3:0] a, b; } sp_t;
  endclass

  class shape;
    holder::arr_t  c_qual_arrtd;            // scalar arm: whole-array typedef
    holder::q_t    c_qual_qtd;              // scalar arm: queue typedef
    holder::st_t   c_qual_ustruct;          // unpacked struct, qualified
    holder::sp_t   c_qual_pstruct;          // packed struct, qualified
    holder::e_t    c_qual_dyn[];            // ARRAY arm over a qualified elem
    holder::e_t    c_qual_q[$];             // QUEUE arm over a qualified elem
  endclass

  // NON-class scopes, the controls
  holder::e_t p_pkgvar;                     // PACKAGE variable, class-qualified
endpackage

module top;
  p1::holder::e_t m_modvar;                 // MODULE variable, class-qualified
  p1::shape s;
  function automatic void f();
    p1::holder::e_t l_fnlocal;              // FUNCTION local, class-qualified
    l_fnlocal = p1::holder::H_A;
  endfunction
  initial begin s = new(); f(); end
endmodule
