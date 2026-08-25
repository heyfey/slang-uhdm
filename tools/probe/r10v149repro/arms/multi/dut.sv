// v149d arm -- MULTIPLE DECLARATORS on ONE struct member declaration, mixing
// dimensioned and undimensioned names, plus a queue whose element is a queue
// TYPEDEF and a member named the same as its type.
package Lam9_pkg;
  typedef string strq_t[$];
  typedef struct {
    string  mdA[$], mdB;
    int     mdC, mdD[$], mdE[3];
    strq_t  mdTdef;
    string  mdTail[$];
  } multi_t;
  multi_t theMulti;
endpackage

module multi_top;
  import Lam9_pkg::*;
  multi_t m9;
  initial m9.mdC = 7;
endmodule
