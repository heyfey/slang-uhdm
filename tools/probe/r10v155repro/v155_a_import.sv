// r10v155 arm A — IMPORTS.  A statement-scope typedef whose bare name is also a
// PACKAGE typedef reached by WILDCARD import, by EXPLICIT import, and used
// SCOPED.  MEASUREMENT ONLY.
package pkgA155v;
  typedef bit [6:0]  wideName155v;   // shares its name with a stmt-scope td below
  typedef int        explName155v;   // ditto, reached by explicit import
  typedef logic [3:0] soloName155v;  // never shadowed — a control
  class ClsA155v;
    int fieldA;
  endclass
endpackage

// A1: WILDCARD import + a stmt-scope typedef of the same name.
module mWild155v;
  import pkgA155v::*;
  initial begin
    typedef byte wideName155v;          // shadows the wildcard-imported one
    wideName155v wildVal155v;           // ?
    soloName155v ctlWild155v;           // control: resolves
    wildVal155v = 8'd1;
    ctlWild155v = 4'd2;
  end
endmodule

// A2: EXPLICIT import + a stmt-scope typedef of the same name.
module mExpl155v;
  import pkgA155v::explName155v;
  function automatic int fExpl155v();
    typedef shortint explName155v;      // shadows the explicitly-imported one
    explName155v explVal155v;
    explVal155v = 3;
    return int'(explVal155v);
  endfunction
  int rExpl155v;
  initial rExpl155v = fExpl155v();
endmodule

// A3: SCOPED use of the package typedef next to a stmt-scope typedef of the
// same bare name — the scoped one must not move.
module mScoped155v;
  initial begin
    typedef byte wideName155v;
    wideName155v          bareScoped155v;   // ?
    pkgA155v::wideName155v pkgScoped155v;   // control: scoped, resolves
    bareScoped155v = 8'd3;
    pkgScoped155v = 7'd4;
  end
endmodule

// A4: a stmt-scope typedef whose name is a CLASS reached by EXPLICIT import.
module mClsImp155v;
  import pkgA155v::ClsA155v;
  initial begin
    typedef int ClsA155v;               // shadows the imported class name
    ClsA155v clsImpVal155v;             // ?
    clsImpVal155v = 5;
  end
endmodule

// A5: a stmt-scope typedef whose name is a CLASS reached by WILDCARD import.
module mClsWild155v;
  import pkgA155v::*;
  initial begin
    typedef int ClsA155v;
    ClsA155v clsWildVal155v;            // ?
    clsWildVal155v = 6;
  end
endmodule
