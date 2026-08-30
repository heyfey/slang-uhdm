// r10uvm166 GRID E -- THE DECLINE ARM.  MEASUREMENT ONLY.
// Every cell here is a shape the law must NOT move: a different declaration
// SITE (class property, module variable, formal, return), a dimension written
// on the declarator, a PACKAGE / $unit home, a STATEMENT-SCOPE typedef
// (sec. blockLocalTdDeclIsRefVarUnsupported155's family), a `virtual` base, a
// paren-less function body, and the keyword / inline-enum bases.
package ek166;
  class Rung166;  int step166; endclass
  typedef enum { NORTH166, SOUTH166 } gale166_e;
  typedef gale166_e pkgGaleQ166_t[$];

  class Ladder166;
    typedef gale166_e galeQ166_t[$];
    typedef int       tallyQ166_t[$];
    typedef enum { UPPER166, LOWER166 } inlQ166_t[$];

    galeQ166_t propVal166;
    static galeQ166_t statPropVal166;

    function void climb166(galeQ166_t argVal166);
      galeQ166_t declDimVal166 [2];
      tallyQ166_t keyBaseVal166;
      inlQ166_t   inlBaseVal166;
      pkgGaleQ166_t pkgHomeVal166;
      begin
        typedef gale166_e blkQ166_t[$];
        blkQ166_t blkVal166;
        blkVal166 = argVal166;
      end
      keyBaseVal166 = '{1};
      pkgHomeVal166 = argVal166;
    endfunction

    function galeQ166_t hoist166();
      hoist166 = propVal166;
    endfunction

    function void noParen166;
      galeQ166_t parenLessVal166;
      parenLessVal166 = propVal166;
    endfunction
  endclass
endpackage

typedef int hoop166_t;
typedef hoop166_t hoopQ166_t[$];

interface rail166;
  logic clk166;
endinterface

module yard166;
  import ek166::*;
  typedef gale166_e yardQ166_t[$];
  yardQ166_t modVarVal166;
  typedef virtual rail166 vifQ166_t[$];
  function automatic void shunt166();
    vifQ166_t  vifVal166;
    hoopQ166_t unitHomeVal166;
    unitHomeVal166 = '{2};
    vifVal166.delete();
  endfunction
  initial begin
    modVarVal166.delete();
    shunt166();
  end
endmodule
