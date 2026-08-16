// r10sd10 grid cell g5 — NEGATIVE CONTROL for the existing gate.
// The SAME "owner not compiled yet" situation reached through the BARE
// (unscoped) name arm of Surelog's compileVariable instead of the
// `paClass_scope` arm.  The bare arm's fallback chain ends at `ref_var`, NOT
// `class_var`, so a gate that keys only on "the owner's typedefs had to be
// built on demand" must NOT fire here.
package px;

  class kx;
    int q;
  endclass

  class zbase;
    typedef struct { int a; } zrec_t;
    typedef kx zcls_t;                 // class-handle typedef, owner sorts AFTER
    typedef enum { ZA, ZB } zenum_t;
  endclass

  class abase;                       // sorts BEFORE zbase
    typedef struct { int a; } arec_t;
    function void f();
      arec_t v_own_bare;             // own typedef, BARE
      v_own_bare.a = 1;
    endfunction
  endclass

  class achild extends zbase;        // parent sorts AFTER the child
    function void g();
      zrec_t v_inherited_bare;       // INHERITED typedef, BARE name
      zcls_t v_inherited_cls;        // INHERITED class-handle typedef, BARE
      zenum_t v_inherited_enum;      // INHERITED enum typedef, BARE
      zbase::zrec_t v_inherited_scoped;  // the SAME typedef, SCOPED
      v_inherited_bare.a = 1;
      v_inherited_scoped.a = 1;
      v_inherited_enum = ZA;
    endfunction
  endclass

endpackage

module top;
  px::abase a;
  px::achild c;
  initial begin a = new(); c = new(); end
endmodule
