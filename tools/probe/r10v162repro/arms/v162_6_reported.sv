// r10v162 arm 6 — THE REPORTED-ERROR TWIN.  An EXPLICIT specialization whose
// type argument does NOT carry the member makes slang REPORT the bad access
// rather than swallow it, and a reported error is a NON-ZERO exit and
// SLANG_REJECT (out of scope by decision).  This arm must stay SLANG_REJECT on
// BOTH binaries with the SAME rc — the law must not convert a reported error
// into a silently-recovered database.  MEASUREMENT ONLY.
package Rep6_pkg;
  class Cell6 #(type SLOT = int);
    static string acc = "";
    string q;
    SLOT sl;
    function void r1(); acc = {"[", q=="" ? "a" : "b", "]", sl.absent()}; endfunction
  endclass
endpackage

module Top_Rep6;
  import Rep6_pkg::*;
  Cell6 #(int) c6;   // an EXPLICIT specialization: `int` has no `absent()`
  initial $display("rep6");
endmodule
