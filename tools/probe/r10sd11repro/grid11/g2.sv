// r10sd11 grid cell g2 — THE ORDER CONTROL.  Byte-for-byte g1 with the owners
// RENAMED so they sort BEFORE the declaring class and are therefore COMPILED
// FIRST.  If compile order decides the TYPESPEC the way it decides the variable
// KIND (§ classTdLocalVarKindFollowsCompileOrder10), every cell here must
// RESOLVE.  If the discriminator is the typedef's WRITTEN TARGET instead, the
// class-name typedefs must degrade here too.
package px2;

  class aholda2;
    typedef int i_t;
    typedef enum { A2, B2 } e_t;
    typedef struct { int a; } s_t;
    typedef struct packed { int a; } sp_t;
    typedef logic [7:0] v_t;
    typedef string t_t;
    typedef int m_t[string];
    typedef int n_t[4];
  endclass

  class aelem2;
    int q;
  endclass

  class aholdb2;
    typedef aelem2 c_t;
    typedef aelem2 cq_t[$];
    typedef aelem2 ca_t[string];
    typedef aholda2::s_t ss_t;
  endclass

  class zuser2;
    function void f2();
      aholda2::i_t   a_i;
      aholda2::e_t   a_e;
      aholda2::s_t   a_s;
      aholda2::sp_t  a_sp;
      aholda2::v_t   a_v;
      aholda2::t_t   a_t;
      aholda2::m_t   a_m;
      aholda2::n_t   a_n;
      aholdb2::c_t   a_c;
      aholdb2::cq_t  a_cq;
      aholdb2::ca_t  a_ca;
      aholdb2::ss_t  a_ss;
      aholdb2::c_t   a_carr[4];
    endfunction
  endclass

endpackage

module top2;
  initial begin
    px2::zuser2 u = new();
    u.f2();
  end
endmodule
