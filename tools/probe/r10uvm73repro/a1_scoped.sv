// r10uvm73 arm a1 — THE CLASS-SCOPE-QUALIFIED TYPE AXIS, UVM-free.
//
// uvm-1.2 writes the head's declaration as
//     uvm_sequencer_base::seq_req_t  request;      (uvm_sequencer_base.svh:1771)
// i.e. a class PROPERTY whose declared TYPE is named with a CLASS-SCOPE
// QUALIFIER (`C::t`).  Surelog emits a bare `logic_var` with NO vpiTypespec at
// all for that; we emit `enum_var` + ref_typespec -> enum_typespec.
//
// This arm holds the DECLARATION SITE and the TARGET TYPE as axes and asks, per
// cell, what golden's KIND and TYPESPEC PRESENCE are.  The brief's hypothesis
// (Surelog cannot RESOLVE the name from the using scope) predicts the SAME
// degradation for every unqualified cross-class use; the qualification
// hypothesis predicts it only where `::` appears.
package p1;

  typedef enum {P_A, P_B} pkg_e_t;                      // package-scope enum
  typedef struct packed { bit [1:0] q; } pkg_s_t;       // package-scope struct

  class holder;
    typedef enum {H_A, H_B} e_t;                        // class-scope enum
    typedef struct packed { bit [3:0] a, b; } s_t;      // class-scope struct
    typedef int i_t;                                    // class-scope plain
    typedef logic [7:0] v_t;                            // class-scope vector
  endclass

  class user;
    typedef enum {U_A, U_B} own_e_t;                    // OWN-class enum

    // ---- class PROPERTIES ------------------------------------------------
    holder::e_t   c_qual_enum;        // THE HEAD'S SHAPE
    holder::s_t   c_qual_struct;
    holder::i_t   c_qual_int;
    holder::v_t   c_qual_vec;
    own_e_t       c_own_enum;         // own-class typedef, UNQUALIFIED
    pkg_e_t       c_pkg_enum;         // package typedef, unqualified
    pkg_s_t       c_pkg_struct;
    p1::pkg_e_t   c_pkgqual_enum;     // package typedef, PACKAGE-QUALIFIED
    holder::e_t   c_qual_enum_arr[3]; // same type under an ARRAY wrapper
    holder::e_t   c_qual_enum_aa[string];
    holder        c_class_handle;     // a plain class handle, for contrast

    // ---- function LOCALS and ARGUMENTS ------------------------------------
    function void m();
      holder::e_t l_qual_enum;
      holder::s_t l_qual_struct;
      own_e_t     l_own_enum;
      pkg_e_t     l_pkg_enum;
      l_qual_enum = holder::H_A;
      l_own_enum  = U_A;
      l_pkg_enum  = P_A;
      l_qual_struct = '0;
    endfunction

    function void n(holder::e_t a_qual_enum, own_e_t a_own_enum,
                    pkg_e_t a_pkg_enum);
    endfunction
  endclass

  // ---- the type's OWN class declares a property of its own typedef ---------
  class selfuser;
    typedef enum {S_A, S_B} s_e_t;
    s_e_t        c_self_enum;         // own typedef, unqualified, same class
    selfuser::s_e_t c_self_qual_enum; // own typedef, SELF-QUALIFIED
  endclass

  // ---- INHERITANCE: the typedef comes from the base class -----------------
  class derived extends holder;
    e_t          c_inh_enum;          // inherited typedef, UNQUALIFIED
    holder::e_t  c_inh_qual_enum;     // same typedef, base-name QUALIFIED
  endclass

endpackage

// ---- $unit-scope class, outside any package -------------------------------
class uholder;
  typedef enum {X_A, X_B} e_t;
endclass

class uuser;
  uholder::e_t c_unit_qual_enum;      // $unit class-scope qualified
endclass

module top;
  import p1::*;
  p1::user   u;
  p1::pkg_e_t     m_pkgqual_enum;     // package-qualified, MODULE variable
  pkg_e_t         m_pkgimp_enum;      // wildcard-imported, module variable
  p1::holder::e_t m_pkgclass_enum;    // pkg::class::typedef, module variable
  uholder::e_t    m_unit_qual_enum;   // $unit class-scope qualified, module
  initial begin
    u = new();
    u.m();
  end
endmodule
