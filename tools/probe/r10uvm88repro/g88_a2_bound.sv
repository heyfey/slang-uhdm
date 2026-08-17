// r10uvm88 arm a2 — THE BOUNDARY.  Everything an in-body class method can read
// out of its home package that is NOT a VARIABLE must stay exactly as pristine
// leaves it, because § classImportParamStamped82 owns package PARAMETER refs
// from classes and § pkgSubRefBindsPkgVarOverFormal81 owns the formal contest.
package b88;
  parameter  int PAR88  = 4;          // package PARAMETER  (§82's family)
  localparam int LPAR88 = 5;          // package LOCALPARAM
  typedef enum int { E88A = 1, E88B } e88_t;   // package ENUM CONSTANTS
  const string cv88 = "CV";           // package const VARIABLE (this law)
  int          nv88 = 6;              // package plain VARIABLE (this law)
  function int bf88(int x); return x + 1; endfunction   // package FUNCTION

  class k88;
    int    i;
    string s;
    e88_t  e;
    // IN-BODY: only the two VARIABLE reads may move.
    function void inb88();
      i = PAR88;          // parameter   — must NOT move
      i = LPAR88;         // localparam  — must NOT move
      e = E88A;           // enum const  — must NOT move
      i = bf88(2);        // function    — must NOT move
      s = cv88;           // const var   — MOVES
      i = nv88;           // plain var   — MOVES
    endfunction
    // A FORMAL that shadows a package variable, read in an IN-BODY method:
    // § 81's contest never reaches an in-body method (no package Instance).
    function void shad88(string cv88);
      s = cv88;           // the FORMAL — must NOT move
    endfunction
    // A LOCAL that shadows a package variable
    function void loc88();
      string nv88;
      nv88 = "L";
      s = nv88;           // the LOCAL — must NOT move
    endfunction
    extern function void oob88();
  endclass

  // OUT-OF-BODY: nothing here may move.
  function void k88::oob88();
    i = PAR88;
    i = LPAR88;
    e = E88A;
    i = bf88(2);
    s = cv88;
    i = nv88;
  endfunction
endpackage

module topb88;
  b88::k88 h;
  initial h = new();
endmodule
