// r10v166 ARM A — USE-SITE stress for § nameBasedArrayTdDeclIsRefVar166.
// The law replaces an array_var+element PAIR with ONE ref_var.  Every way a
// SystemVerilog program can USE that local is exercised here, because the
// emitter's select / foreach / method-call / argument paths all look the
// declaration up in netMap/funcMap and previously always found an array_var.
package ua166_pkg;

  class Leaf166;
    int tag;
    function new(int t = 0); tag = t; endfunction
  endclass

  class Bag166 #(type ELEM166 = Leaf166);
    typedef ELEM166   elemq166_t [$];          // NAME base, queue     -> FIRES
    typedef ELEM166   elemd166_t [];           // NAME base, dynamic   -> FIRES
    typedef ELEM166   elema166_t [string];     // NAME base, assoc     -> FIRES
    typedef ELEM166   elemf166_t [4];          // NAME base, fixed     -> FIRES
    typedef int       intq166_t  [$];          // KEYWORD base         -> declines

    ELEM166 prop166 [$];                       // class PROPERTY, never moved

    // --- SELECT + SIZE + BUILT-IN METHODS on a degraded local
    function int useSel166(int n);
      elemq166_t qv166;                        // <- degraded
      ELEM166    one166;
      int        acc166;
      qv166 = {};
      one166 = new(n);
      qv166.push_back(one166);
      qv166.push_front(one166);
      acc166 = qv166.size();
      one166 = qv166[0];                       // INDEX SELECT of a ref_var
      acc166 += qv166[0].tag;                  // member select through it
      qv166.delete(0);
      return acc166;
    endfunction

    // --- FOREACH over a degraded local, and over a degraded ASSOC local
    function int useForeach166();
      elemq166_t qv166;
      elema166_t av166;                        // <- degraded assoc
      int        acc166;
      acc166 = 0;
      foreach (qv166[i166])
        acc166 += qv166[i166].tag;
      foreach (av166[k166])
        acc166 += av166[k166].tag;
      if (av166.exists("x")) acc166++;
      return acc166;
    endfunction

    // --- WHOLE-ARRAY ASSIGNMENT both ways, and an INITIALISED declaration
    function elemq166_t useAssign166(elemq166_t seed166);
      elemq166_t out166 = seed166;             // INITIALISED degraded local
      elemd166_t dyn166;                       // <- degraded dynamic
      elemf166_t fix166;                       // <- degraded fixed
      dyn166 = new[3];
      out166 = seed166;
      fix166[0] = seed166[0];
      dyn166[0] = fix166[0];
      return out166;
    endfunction

    // --- PASSED AS AN ARGUMENT (by value and by ref) and RETURNED
    function automatic void useArgs166(ref elemq166_t byref166,
                                       input elemq166_t byval166);
      elemq166_t local166;                     // <- degraded
      local166 = byval166;
      byref166 = local166;
    endfunction

    // --- THREE DECLARATORS off ONE declaration, plus a KEYWORD-based twin
    function int useMulti166();
      elemq166_t a166, b166, c166;             // <- three degraded
      intq166_t  k166;                         // <- declines (keyword base)
      int        n166;
      a166 = {}; b166 = a166; c166 = b166;
      k166 = {1, 2};
      n166 = a166.size() + b166.size() + c166.size() + k166.size();
      return n166;
    endfunction

    // --- NESTED begin / fork / for-body / case-item homes for the same shape
    task useHomes166(int sel166);
      elemq166_t top166;
      begin : nest166
        elemq166_t in166;                      // <- degraded, nested begin
        in166 = top166;
      end
      fork
        begin : farm166
          elemq166_t fk166;                    // <- degraded, fork arm
          fk166 = top166;
        end
      join_none
      for (int i166 = 0; i166 < 2; i166++) begin
        elemq166_t fb166;                      // <- degraded, for body
        fb166 = top166;
      end
      case (sel166)
        0: begin
             elemq166_t cs166;                 // <- degraded, case item
             cs166 = top166;
           end
        default: ;
      endcase
    endtask
  endclass

  // OUT-OF-BODY method body, and a nested begin inside it
  class Oob166;
    typedef Leaf166 oq166_t [$];
    extern function int oobUse166();
  endclass

  function int Oob166::oobUse166();
    oq166_t ov166;                             // <- degraded, out-of-body
    int r166;
    begin : oobnest166
      oq166_t on166;                           // <- degraded, nested
      on166 = ov166;
    end
    r166 = ov166.size();
    return r166;
  endfunction

  // A PACKAGE FREE FUNCTION that names a CLASS-homed typedef through a
  // handle's type is NOT expressible bare, so the package's own typedef is
  // used instead — the DECLINE control at package home.
  typedef Leaf166 pkgq166_t [$];
  function automatic int pkgUse166();
    pkgq166_t pv166;                           // <- declines (package home)
    return pv166.size();
  endfunction

endpackage

module ua166_top;
  import ua166_pkg::*;
  Bag166 #(Leaf166) bag166;
  int r166;
  initial begin
    bag166 = new();
    r166 = bag166.useSel166(3) + bag166.useForeach166() + bag166.useMulti166()
           + pkgUse166();
  end
endmodule
