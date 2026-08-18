// v91 arm 3 — TYPEDEF COUNT/ORDER PERMUTATIONS over a 3-parameter chain, and
// USE SITES beyond the implementer's c_sites (constraints, virtual methods,
// static props, parameter-name-written formals, extern methods, covergroups).
package pv3;
  // all six order permutations of typedefs a_t/b_t/c_t over A,B=A,C=B
  class o_abc #(type A=int, type B=A, type C=B); typedef A a_t; typedef B b_t; typedef C c_t; A p; endclass
  class o_acb #(type A=int, type B=A, type C=B); typedef A a_t; typedef C c_t; typedef B b_t; A p; endclass
  class o_bac #(type A=int, type B=A, type C=B); typedef B b_t; typedef A a_t; typedef C c_t; A p; endclass
  class o_bca #(type A=int, type B=A, type C=B); typedef B b_t; typedef C c_t; typedef A a_t; A p; endclass
  class o_cab #(type A=int, type B=A, type C=B); typedef C c_t; typedef A a_t; typedef B b_t; A p; endclass
  class o_cba #(type A=int, type B=A, type C=B); typedef C c_t; typedef B b_t; typedef A a_t; A p; endclass

  // COUNT permutations: typedef on exactly one of the three
  class n_a #(type A=int, type B=A, type C=B); typedef A a_t; A p_a; B p_b; C p_c; endclass
  class n_b #(type A=int, type B=A, type C=B); typedef B b_t; A p_a; B p_b; C p_c; endclass
  class n_c #(type A=int, type B=A, type C=B); typedef C c_t; A p_a; B p_b; C p_c; endclass
  // exactly two
  class n_ab #(type A=int, type B=A, type C=B); typedef A a_t; typedef B b_t; A p_a; C p_c; endclass
  class n_ac #(type A=int, type B=A, type C=B); typedef A a_t; typedef C c_t; A p_a; B p_b; endclass
  class n_bc #(type A=int, type B=A, type C=B); typedef B b_t; typedef C c_t; A p_a; B p_b; endclass

  // NAME-SORT vs DECLARATION-ORDER separator: typedef names sort OPPOSITE to
  // the parameter declaration order (z_t on A, a_t on C).
  class s_rev #(type A=int, type B=A, type C=B);
    typedef A z_t;
    typedef C a_t;
    A p_a; C p_c;
  endclass

  // ALL SITES on one group
  virtual class c_allsites #(type A=int, type B=A);
    typedef A a_t;
    typedef B b_t;
    static A s_static;
    rand A r_rand;
    A p_arr[2][3];
    b_t p_td;
    A p_pubs;
    local A p_loc;
    protected b_t p_prot;
    constraint cc { r_rand inside {0, 1}; }
    virtual function void v_fn(a_t x); endfunction
    pure virtual function b_t pv_fn();
    extern function void e_fn(A x);
    function automatic void auto_fn();
      automatic b_t l_auto = 0;
      static A l_stat = 0;
    endfunction
    task t_task(ref a_t x); endtask
    function b_t chain_ret(A i, b_t j); return j; endfunction
  endclass
  function void c_allsites::e_fn(A x); endfunction

  // the typedef written for a NON-root parameter used as a BASE specialization
  class c_use #(type A=int, type B=A);
    typedef B b_t;
    A p_a;
  endclass
  class c_use2 extends c_use #(int, int);
    b_t p_inherited;
  endclass
endpackage

module topv3;
  import pv3::*;
  o_abc u1; o_acb u2; o_bac u3; o_bca u4; o_cab u5; o_cba u6;
  n_a u7; n_b u8; n_c u9; n_ab u10; n_ac u11; n_bc u12;
  s_rev u13; c_use u15; c_use2 u16;
endmodule
