// r10sd10 grid cell g4 — the OWNER-REACH axis.  Surelog's `paClass_scope` arm
// resolves the owner with THREE lookups and nothing else:
//     getClassDefinition(<written scope name>)
//     getClassDefinition(<declaring component's own full name> :: <scope name>)
//     getClassDefinition(<declaring component's PARENT scope name> :: <scope name>)
// so an owner that is not the design's bare name, not nested in the declaring
// class, and not a sibling in the declaring class's own parent scope is NEVER
// reached — and the declaration falls back to `class_var` whatever the sort
// order says.  This cell scores each reach separately.
package qy;
  class aqholder;                        // sorts BEFORE any px class user
    typedef struct { int a; } qsrec_t;
  endclass
endpackage

package px;
  import qy::*;

  class aholder;                         // SAME package, sorts BEFORE
    typedef struct { int a; } srec_t;
  endclass

  class self_user;                       // uses its OWN nested typedef, scoped
    typedef struct { int a; } orec_t;
    function void f();
      self_user::orec_t v_self;
      v_self.a = 1;
    endfunction
  endclass

  class outer_c;
    class inner_c;                       // CLASS-NESTED class
      typedef struct { int a; } irec_t;
    endclass
    function void f();
      inner_c::irec_t v_inner;           // nested in the DECLARING class
      v_inner.a = 1;
    endfunction
  endclass

  class buser;
    function void f();
      aholder::srec_t   v_same_pkg;      // sibling in the same package
      aqholder::qsrec_t v_imported;      // owner in ANOTHER package, imported
      v_same_pkg.a = 1;
      v_imported.a = 1;
    endfunction
  endclass

endpackage

module top;
  px::buser b;
  px::self_user su;
  px::outer_c oc;
  initial begin b = new(); su = new(); oc = new(); end
endmodule
