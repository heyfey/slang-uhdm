// r10uvm73 arm a4 — DOES THE DEGRADATION SURVIVE THE QUALIFIERS, and what
// happens to a DECLARATION INITIALIZER on a degraded property.
//
// The head keeps vpiAutomatic + vpiVisibility, and uvm_mem_mam_cfg's `rand
// uvm_mem_mam::alloc_mode_e mode` keeps vpiIsRandomized + vpiRandType:2, so the
// degradation is KIND + TYPESPEC only.  This arm measures every remaining
// qualifier and the two initializer shapes § classPropNullInitParentedByTypespec2
// (r10buvm2) made scope-sensitive — its law is "NO TYPESPEC -> the null constant
// is parented by the CLASS_DEFN", and a degraded property has no typespec.
package p1;
  class holder;
    typedef enum {H_A, H_B} e_t;
    typedef holder   self_t;
    typedef string   s_t;
    typedef chandle  ch_t;
    typedef int      i_t;
  endclass

  class qual;
    holder::e_t             c_plain;
    rand holder::e_t        c_rand;
    randc holder::i_t       c_randc;
    static holder::e_t      c_static;
    const holder::i_t       c_const = 3;
    protected holder::e_t   c_prot;
    local holder::e_t       c_local;
    holder::self_t          c_null   = null;      // null init on a DEGRADED prop
    holder::i_t             c_intinit = 7;        // integer init, degraded
    holder::i_t             c_neg    = -1;        // NEGATED int init, degraded
    holder::s_t             c_str;                // string typedef, qualified
    holder::ch_t            c_chand;              // chandle typedef, qualified
  endclass

  // the CONTROLS: the same qualifiers over an OWN-class typedef
  class ctrl;
    typedef enum {C_A, C_B} e_t;
    typedef ctrl            self_t;
    typedef int             i_t;
    e_t                     k_plain;
    rand e_t                k_rand;
    static e_t              k_static;
    const i_t               k_const = 3;
    protected e_t           k_prot;
    self_t                  k_null = null;
    i_t                     k_intinit = 7;
    i_t                     k_neg     = -1;
  endclass
endpackage

module top;
  p1::qual q; p1::ctrl k;
  initial begin q = new(); k = new(); end
endmodule
