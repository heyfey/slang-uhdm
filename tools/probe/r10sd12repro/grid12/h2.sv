// r10sd12 grid cell h2 — THE OUT-OF-BODY ARM, which is the corpus's OTHER
// direction.  `uvm_default_factory::m_resolve_type_name_by_inst` is an
// `extern` method whose body is written at FILE scope, so Surelog's
// FileContent pass compiles it before any class exists and NOTHING resolves —
// not even the class's own typedef.  Its `m_inst_typename_alias_t
// type_alias_inst[$];` element is a golden `ref_var` where ours is a
// `struct_var`, the mirror of h1's `class_var`/`ref_var` disagreement.
//
// The cell writes the SAME declarations twice, once in an out-of-body body and
// once in an in-body method of the same class, so the two answers are read off
// ONE golden.
package ph2;

  class zel2;
    int q;
  endclass

  class zown2;
    typedef zel2 o_t;
  endclass

  class ahost2;
    typedef zel2                     own_t;   // the host's OWN typedef, bare
    typedef struct { int a; string b; } rec_t;  // an in-place STRUCT typedef

    extern function void ext2();
    function void inb2();
      own_t     i_own_q[$];
      rec_t     i_rec_q[$];
      zown2::o_t i_sc_q[$];
      rec_t     i_rec_fx[3];
    endfunction
  endclass

  function void ahost2::ext2();
    own_t      e_own_q[$];     // BARE own typedef, OUT-OF-BODY -> ref_var
    rec_t      e_rec_q[$];     // BARE in-place struct, OUT-OF-BODY -> ref_var
    zown2::o_t e_sc_q[$];      // SCOPED, out-of-body -> class_var
    rec_t      e_rec_fx[3];    // the fixed-size form of the same question
    e_own_q = {};
  endfunction

endpackage

module toph2;
  initial begin
    ph2::ahost2 h = new();
    h.ext2();
    h.inb2();
  end
endmodule
