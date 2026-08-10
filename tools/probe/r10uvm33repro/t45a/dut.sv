// t45a — the class-scope typedef GROUP and its LAST-WINS name.
//
// t41b §(c) established the shape on ONE cell: `imp31`'s three typedefs of
// three type parameters that all resolve to `int` share ONE typespec named
// after the LAST, and the formals written as the PARAMETERS point at it too,
// while a group of one (`shortint`, a class) keeps its own name.  That is
// enough to see the law but NOT enough to write the predicate.  The cells the
// implementation actually has to decide, each with its control:
//
//  (A) is it the LAST *DECLARED* typedef?  `ord45` declares them out of order.
//  (B) a GROUP OF ONE with a PARAMETER-written formal and a PLAIN `int`
//      formal — t41b has neither, and both are inside the blast radius of any
//      predicate that binds parameter spellings.
//  (C) does a typedef that is NOT of a type parameter (`typedef int m_plain_t`)
//      JOIN the group, and can it WIN the name?
//  (D) is the law about `int`, or about any resolved type?  A shortint group
//      of two and a CLASS group of two.
//  (E) two DIFFERENT integer types in one class — one group or two?
//  (F) an EXPLICIT specialization: does the group re-form per specialization?
//  (G) a DERIVED class over a parameterised base.
package p45;
  class base45; int z; endclass
  class other45; int w; endclass

  // (A) declared out of order: c_t FIRST, b_t LAST.
  class ord45 #(type A = int, type B = A, type C = A);
    typedef C c_t;
    typedef A a_t;
    typedef B b_t;
    virtual function void f_td (input a_t x, input b_t y, input c_t z);
    endfunction
    virtual function void f_par(input A x, input B y, input C z);
    endfunction
  endclass

  // (B) a group of ONE, all three spellings.
  class one45 #(type A = int);
    typedef A a1_t;
    virtual function void g_td (input a1_t x); endfunction
    virtual function void g_par(input A x);    endfunction
    virtual function void g_raw(input int x);  endfunction
  endclass

  // (C) a PLAIN typedef of int among type-parameter typedefs.
  class mix45 #(type A = int, type B = A);
    typedef A m_a_t;
    typedef int m_plain_t;
    typedef B m_b_t;
    virtual function void h_a  (input m_a_t x);     endfunction
    virtual function void h_b  (input m_b_t x);     endfunction
    virtual function void h_pl (input m_plain_t x); endfunction
    virtual function void h_raw(input int x);       endfunction
  endclass

  // (D) a non-`int` builtin group of two, and a CLASS group of two.
  class kind45 #(type S = shortint, type T = S,
                 type U = base45,   type V = U);
    typedef S s_t;
    typedef T t_t;
    typedef U u_t;
    typedef V v_t;
    virtual function void k_s(input s_t a, input t_t b); endfunction
    virtual function void k_u(input u_t a, input v_t b); endfunction
  endclass

  // (E) two DIFFERENT integer types: `int` and `integer`.
  class two45 #(type A = int, type B = integer, type C = A);
    typedef A x_t;
    typedef B y_t;
    typedef C z_t;
    virtual function void w45(input x_t a, input y_t b, input z_t c);
    endfunction
  endclass

  // (F) the same shape, specialised explicitly as well as by default.
  class spec45 #(type A = int, type B = A, type C = A);
    typedef A sa_t;
    typedef B sb_t;
    typedef C sc_t;
    virtual function void sf(input sa_t a, input sb_t b, input sc_t c);
    endfunction
  endclass

  // (H) a same-typed parameter with NO typedef, in a class that HAS a group.
  //     UVM's `uvm_master_imp #(REQ=int, RSP=int, IMP=int, REQ_IMP=IMP,
  //     RSP_IMP=IMP)` is exactly this: `new`'s three typedef-aliased
  //     parameters share the named object, and `get(output REQ t)` does NOT.
  class nod45 #(type A = int, type B = A, type N = int);
    typedef A na_t;
    typedef B nb_t;
    virtual function void n_td (input na_t x, input nb_t y); endfunction
    virtual function void n_par(input N q);                  endfunction
  endclass

  // (G) a derived class over a parameterised base.
  class der45 extends ord45 #();
    virtual function void d_own(input int q); endfunction
  endclass
endpackage

module top45;
  import p45::*;
  ord45 #()  o;
  one45 #()  n;
  mix45 #()  mx;
  kind45 #() k;
  two45 #()  t2;
  nod45 #()  nd;
  spec45 #(shortint, shortint, shortint) sp;
  spec45 #() sp0;
  der45      d;
  initial begin
    o = new(); n = new(); mx = new(); k = new(); t2 = new(); nd = new();
    sp = new(); sp0 = new(); d = new();
  end
endmodule
