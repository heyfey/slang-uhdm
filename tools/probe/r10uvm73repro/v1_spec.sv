// r10uvm73 VERIFIER arm v1 — THE EMPTY PRODUCT CELLS OF THE SCOPE AXIS.
//
// The implementer's grid measured `pholder#(int)::g_e_t` (a PARAMETERISED class
// scope, QUALIFIED) and found it degrades.  It never measured the CONTROL that
// the predicate's clause (3a) most plausibly breaks:
//
//     a PARAMETERISED class's OWN typedef, used BARE, INSIDE that same class.
//
// clause (3a) is `&home->asSymbol() != &ownerCls  ->  return true`, an IDENTITY
// comparison on slang Symbol addresses.  For a generic class every
// SPECIALIZATION is its own ClassType symbol, and a typedef declared in the
// generic body belongs to the specialization that elaborated it.  If
// emitClassDefn is ever reached with a `cls` that is a DIFFERENT specialization
// (or the uninstantiated default) from the one the TypeAlias was elaborated in,
// clause (3a) fires on a property that golden keeps fully typed — a FALSE
// POSITIVE, and one no cell in the shipped grid could have caught.
//
// It also measures three more products the grid leaves empty:
//   * a NESTED class (typedef in the OUTER class, property in an INNER one),
//   * a typedef inherited through a PARAMETERISED base,
//   * the class's own typedef written with a PACKAGE-QUALIFIED self scope
//     (`p1::holder::e_t` inside holder), i.e. clause (3b)'s ScopedName test
//     reached through two `::` rather than one.
package p1;

  // ---- the FALSE-POSITIVE control: a generic class, its OWN typedef, BARE ----
  class pgen #(int W = 8);
    typedef logic [W-1:0] pw_t;
    typedef enum {P_A, P_B} pe_t;
    pw_t v_pgen_own;        // own typedef, BARE, in a PARAMETERISED class
    pe_t v_pgen_ownenum;    // ditto, enum
    pgen#(W)::pw_t v_pgen_selfqual;  // own typedef, SELF-QUALIFIED through the param
  endclass

  // two DISTINCT specializations, so at least two ClassType symbols exist
  class pusr8;
    pgen#(8)  h8;
    pgen#(16) h16;
  endclass

  // ---- a typedef inherited through a PARAMETERISED base ----
  class pkid extends pgen#(8);
    pw_t v_pkid_inh;        // base's typedef, BARE  -> expect DEGRADE
    pgen#(8)::pe_t v_pkid_qual;      // ...and qualified
  endclass

  // ---- NESTED classes: typedef in the OUTER, property in the INNER ----
  class outer;
    typedef enum {O_A, O_B} o_e_t;
    typedef int o_i_t;
    o_e_t v_outer_own;               // outer's own typedef in outer  -> NO degrade
    class inner;
      o_e_t   v_inner_bare;          // OUTER's typedef, BARE, from the nested class
      outer::o_e_t v_inner_qual;     // ...and qualified
      typedef enum {I_A, I_B} i_e_t;
      i_e_t   v_inner_own;           // the inner class's OWN typedef  -> NO degrade
    endclass
  endclass

  // ---- clause (3b) through a PACKAGE-QUALIFIED SELF scope ----
  class selfpkg;
    typedef enum {S_A, S_B} sp_e_t;
    sp_e_t             v_selfpkg_bare;   // own, bare      -> NO degrade
    selfpkg::sp_e_t    v_selfpkg_qual;   // own, C::t      -> DEGRADE (grid cell)
    p1::selfpkg::sp_e_t v_selfpkg_pkgqual; // own, pkg::C::t -> ??? EMPTY CELL
  endclass

  // ---- an UNPACKED UNION typedef in a class scope (kind decode arm) ----
  class uholder;
    typedef union { int a; bit [31:0] b; } u_t;
    typedef struct packed { bit [3:0] x; bit [3:0] y; } sp_t;
  endclass
  class uusr;
    uholder::u_t  v_qual_union;      // class-qualified UNPACKED-union typedef
    uholder::sp_t v_qual_pstruct;    // control, already in the grid
  endclass

endpackage

module top;
  p1::pusr8 a;
  p1::pkid  b;
  p1::outer c;
  p1::outer::inner d;
  p1::selfpkg e;
  p1::uusr    f;
  initial begin a=new(); b=new(); c=new(); d=new(); e=new(); f=new(); end
endmodule
