// r10v182 arm H — THE ORDERING BREAK.  § pkgCloneMember10 REFUSES a struct
// type declared INSIDE a class (LAW C: "a type declared inside a class is
// invisible from the clone's symbol table"), so for a queue whose element
// struct is CLASS-SCOPED and carries a member named `size`, bindMember10
// returns false and § builtinArrayReadBindsMintedFuncCall182 gets the element.
// UHDM's `DeepClone` has no such scope rule — its second switch walks the
// struct_typespec's Members() whatever scope declared it — so if golden binds
// the MEMBER here, the patch OVER-FIRES.
//   H1  package-scope element struct with a member `size`   (the known cell)
//   H2  CLASS-scope element struct with a member `size`
//   H3  CLASS-scope element struct with a member `max`
//   H4  a queue of a UNION with a member `size`
package hasp182_home;

  typedef struct { int size; int hasp; } pkgtare182_t;
  typedef union packed { logic [31:0] size; logic [31:0] hasp; } pkguni182_t;

  class cornice182;
    typedef struct { int size; int lath; } clstare182_t;
    // `.max`/`.min` need COMPARABLE elements, so a struct-element queue can
    // only ever reach the mint through `size` — H3 is not writable in legal SV.
    int          rail [$];
    clstare182_t nook [$];
    function automatic int h_cls182();
      int bay [$];
      bay = rail.max;
      return nook.size + bay.size;          // H2 / H3'
    endfunction
  endclass

  function automatic int h_pkg182_fn();
    pkgtare182_t nook [$];
    pkguni182_t  gasket [$];
    int          hob;
    hob = nook.size;                        // H1
    hob = hob + gasket.size;                // H4
    return hob;
  endfunction

endpackage

package hasp182_imp;
  import hasp182_home::*;
  int hasp182_anchor;
endpackage

module hasp182_top;
  initial hasp182_imp::hasp182_anchor = 0;
endmodule
