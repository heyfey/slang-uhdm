// r10uvm185 grid arm C — THE REACH AXIS, on `extern` PROTOTYPES.
//
// § classTdLocalVarKindFollowsCompileOrder10's scoped arm resolves only when
// the owner is a DIRECT CHILD of the DECLARING class's OUTERMOST container and
// that container is NAMEABLE (a package or a module — `$unit` is not).  Every
// one of those questions is currently answered for the DEFINITION listing's
// spelling and context; this arm asks all of them at the PROTOTYPE listing
// instead, which is what the law changes.
//
// It deliberately varies the names so that the sort order is not the same in
// every cell (`aa185` and `zz185` around `mid185`; `nq185` after `mm185`),
// because an arm that agrees only because the ORDER term happened to answer the
// same way is not an arm that tests REACH.

// ---- $unit scope: the container is NOT nameable ---------------------------
class u_ah185;
  typedef struct { int a; } uh_rec;
endclass

class u_user185;
  typedef struct { int o; } u_own;
  extern function u_ah185::uh_rec  c_unit_sibling();   // $unit sibling, scoped
  extern function u_own            c_unit_own_bare();  // own, bare on the proto
  extern function u_user185::u_own c_unit_own_scoped();
endclass

function u_ah185::uh_rec  u_user185::c_unit_sibling();  endfunction
function u_user185::u_own u_user185::c_unit_own_bare(); endfunction
function u_user185::u_own u_user185::c_unit_own_scoped(); endfunction

// ---- module scope: the container IS nameable ------------------------------
module top185c;
  class aa185;
    typedef struct { int a; } aa_rec;
  endclass
  class zz185;
    typedef struct { int z; } zz_rec;
  endclass
  class mid185;
    typedef enum { MO0, MO1 } m_own;
    extern function aa185::aa_rec c_mod_early();
    extern function zz185::zz_rec c_mod_late();
    extern function m_own         c_mod_own_bare();
  endclass
  function aa185::aa_rec mid185::c_mod_early();    endfunction
  function zz185::zz_rec mid185::c_mod_late();     endfunction
  function mid185::m_own mid185::c_mod_own_bare(); endfunction

  mid185 m;
  initial m = new();
endmodule

// ---- NESTED declaring classes: the outermost container decides ------------
package pc185;

  class nq185;                       // sorts AFTER mm185
    typedef struct { int n; } nq_rec;
  endclass

  class outer185;
    typedef struct { int t; } out_rec;
    class inner185;
      typedef struct { int i; } in_rec;
      // the OUTERMOST enclosing class's own typedef, named from two deep
      extern function outer185::out_rec c_outer_td();
      // a TOP-LEVEL sibling of the outermost class
      extern function nq185::nq_rec     c_topsib_td();
      // the inner class's OWN typedef, self-qualified
      extern function inner185::in_rec  c_inner_scoped();
    endclass
    // A NESTED class's out-of-body definitions are written inside the
    // ENCLOSING class, not at package scope (slang: "expected subroutine
    // name" / "use of undeclared identifier" for the package-scope form).
    function outer185::out_rec inner185::c_outer_td();    endfunction
    function pc185::nq185::nq_rec inner185::c_topsib_td(); endfunction
    function outer185::inner185::in_rec inner185::c_inner_scoped(); endfunction
  endclass

endpackage

module top185c2;
  u_user185 uu;
  pc185::outer185::inner185 ii;
  initial begin
    uu = new();
    ii = new();
  end
endmodule
