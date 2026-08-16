// r10sd10 grid cell g1 — THE CORE CELL.
// The SeqDriver head shape: a SUBROUTINE-LOCAL variable whose declared type is
// written as a CLASS-SCOPED name (`ClassName::type_name`).  Every nested type
// kind is declared once in `holder` and used once as a method local in `user`,
// beside the SAME type spelled WITHOUT the class scope, so the grid separates
// "what the type is" from "how the type was written".
package px;

  class holder;
    typedef struct { int a; int b; } srec_t;   // <- uvm_resource_types::access_t
    typedef enum { EA, EB } senum_t;
    typedef int sint_t;
    typedef logic [3:0] svec_t;
    typedef bit [1:0] sbit_t;
    typedef string sstr_t;
  endclass

  class kx;
    int q;
  endclass

  class holder2;
    typedef kx scls_t;                          // class-handle typedef, nested
  endclass

  // the SAME shapes, package-level, written WITHOUT any class scope
  typedef struct { int a; int b; } prec_t;
  typedef enum { PA, PB } penum_t;
  typedef int pint_t;

  class user;
    // class PROPERTIES of the scoped struct type (control: NOT a method local)
    holder::srec_t p_scoped_struct;

    function void f();
      holder::srec_t  a_scoped_struct;   // THE HEAD SHAPE
      holder::senum_t a_scoped_enum;
      holder::sint_t  a_scoped_int;
      holder::svec_t  a_scoped_vec;
      holder::sbit_t  a_scoped_bit;
      holder::sstr_t  a_scoped_str;
      holder2::scls_t a_scoped_cls;
      prec_t          a_pkg_struct;      // plain typedef, no class scope
      penum_t         a_pkg_enum;
      pint_t          a_pkg_int;
      a_scoped_struct.a = 1;
      a_pkg_struct.a = 1;
    endfunction
  endclass

endpackage

module top;
  px::user u;
  initial u = new();
endmodule
