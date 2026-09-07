// r10uvm185 VERIFIER arm M — THE WRITTEN-SCOPE-vs-OWNER AXIS, three instances
// of the one shape the pass's grid never wrote: an `extern` prototype whose
// return type is SCOPED AT THE DECLARING (derived) CLASS while the typedef is
// OWNED BY A BASE class — `der::base_td`, legal SV, the inherited member named
// through the deriving class's own scope.
//
// § classTdLocalVarKindFollowsCompileOrder10's scoped arm checks that the OWNER
// is a direct child of the declaring class's outermost container and that the
// names sort right; it never checks that the WRITTEN scope segment names the
// owner.  Under the pass's patch that arm now decides the PROTOTYPE listing, so
// this shape is decided by a term that was never measured on it.
//
// Instances: package + early-sorting base, package + late-sorting base, and the
// same shape inside a MODULE (whose container IS nameable, so the reach term
// answers differently from `$unit`).
package pm185;

  class ab_m185;                       // sorts BEFORE cd_m185
    typedef enum   { MA0, MA1 } m_enum;
    typedef struct { int a; }   m_rec;
    typedef int                 m_int;
  endclass

  class zb_m185;                       // sorts AFTER  mm_m185
    typedef enum   { MZ0, MZ1 } z_enum;
    typedef struct { int z; }   z_rec;
  endclass

  class cd_m185 extends ab_m185;
    // WRITTEN AT THE DERIVED CLASS, owned by the base
    extern function cd_m185::m_enum m_self_enum();
    extern function cd_m185::m_rec  m_self_rec();
    extern function cd_m185::m_int  m_self_int();
    // the same typedefs written AT THE OWNER — the control
    extern function ab_m185::m_enum m_owner_enum();
    extern function ab_m185::m_rec  m_owner_rec();
  endclass

  class mm_m185 extends zb_m185;
    extern function mm_m185::z_enum m_self_late_enum();
    extern function zb_m185::z_rec  m_owner_late_rec();
  endclass

  function ab_m185::m_enum cd_m185::m_self_enum();      endfunction
  function ab_m185::m_rec  cd_m185::m_self_rec();       endfunction
  function ab_m185::m_int  cd_m185::m_self_int();       endfunction
  function ab_m185::m_enum cd_m185::m_owner_enum();     endfunction
  function ab_m185::m_rec  cd_m185::m_owner_rec();      endfunction
  function zb_m185::z_enum mm_m185::m_self_late_enum(); endfunction
  function zb_m185::z_rec  mm_m185::m_owner_late_rec(); endfunction

endpackage

module top185m;
  class amod185;
    typedef enum   { MM0, MM1 } mm_enum;
    typedef struct { int a; }   mm_rec;
  endclass
  class cmod185 extends amod185;
    extern function cmod185::mm_enum m_mod_self_enum();
    extern function amod185::mm_rec  m_mod_owner_rec();
    extern function mm_enum          m_mod_bare_inh();
  endclass
  function amod185::mm_enum cmod185::m_mod_self_enum();  endfunction
  function amod185::mm_rec  cmod185::m_mod_owner_rec();  endfunction
  function amod185::mm_enum cmod185::m_mod_bare_inh();   endfunction

  pm185::cd_m185 a;
  pm185::mm_m185 b;
  cmod185        c;
  initial begin a = new(); b = new(); c = new(); end
endmodule
