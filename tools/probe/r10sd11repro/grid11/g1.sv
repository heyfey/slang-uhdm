// r10sd11 grid cell g1 — THE TARGET AXIS, owner sorts AFTER the user.
//
// One declaring class `auser1` (whose NAME sorts FIRST, so every owner below is
// compiled LATE by Surelog's lexicographic class pass) reads THIRTEEN
// class-nested typedefs through a SCOPED spelling, as SUBROUTINE BODY LOCALS.
// The question this cell answers is which of them golden binds to a REAL
// typespec and which degrade to an `unsupported_typespec` NAMED AS WRITTEN.
package px1;
  // ORDERING NOTE.  slang refuses `Owner::td` when `Owner` is only
  // forward-declared, so every owner class is written BEFORE its user and the
  // USER class is written LAST.  That costs the cell nothing: Surelog's class
  // pass is LEXICOGRAPHIC (r10sd10 `g8`), and this law's claim order is read
  // off NAMES too, so `auser*` still sorts first and every `z*` owner still
  // sorts after it.

  class zelem1;
    int q;
  endclass

  class zholda1;
    typedef int i_t;
    typedef enum { A1, B1 } e_t;
    typedef struct { int a; } s_t;
    typedef struct packed { int a; } sp_t;
    typedef logic [7:0] v_t;
    typedef string t_t;
    typedef int m_t[string];
    typedef int n_t[4];
  endclass

  class zholdb1;
    typedef zelem1 c_t;
    typedef zelem1 cq_t[$];
    typedef zelem1 ca_t[string];
    typedef zholda1::s_t ss_t;
  endclass

  class auser1;
    function void f1();
      zholda1::i_t   a_i;    // typedef int
      zholda1::e_t   a_e;    // typedef enum declared in place
      zholda1::s_t   a_s;    // typedef struct declared in place
      zholda1::sp_t  a_sp;   // typedef packed struct declared in place
      zholda1::v_t   a_v;    // typedef logic vector
      zholda1::t_t   a_t;    // typedef string
      zholda1::m_t   a_m;    // typedef int assoc
      zholda1::n_t   a_n;    // typedef int fixed unpacked
      zholdb1::c_t   a_c;    // typedef of a CLASS NAME, first by name
      zholdb1::cq_t  a_cq;   // typedef of the SAME class name, queue
      zholdb1::ca_t  a_ca;   // typedef of the SAME class name, assoc
      zholdb1::ss_t  a_ss;   // typedef of a STRUCT TYPEDEF NAME
      zholdb1::c_t   a_carr[4];  // declarator dims on a CLAIMING typedef
    endfunction
  endclass

endpackage

module top1;
  initial begin
    px1::auser1 u = new();
    u.f1();
  end
endmodule
