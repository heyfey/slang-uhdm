// r10uvm154 — the LAYOUT PROOF source.  NOT an arm: it carries NO ENUM at all,
// so § enumWrittenNegDecLit154's code cannot execute on it.  The two binaries
// nevertheless disagree on the value our emitter mints for the class-scoped
// `typedef <T> name[string]` typedefs below — `UINT:22535897` from one and
// `UINT:22539993` from the other, exactly 4096 apart — and that constant sits
// BELOW `\_weaklyReferenced:`, where RESUME.md §9 says the judge cannot reach.
// See layoutproof154.sh and README §7.
package pnq2;
  class C22; int x; endclass
  class K22;
    typedef C22   ka_cls_t[string];
    typedef int   ka_int_t[string];
    function ka_cls_t pc_a_cls();    endfunction
    function ka_int_t pc_a_int();    endfunction
  endclass
endpackage
module topnq2; endmodule
