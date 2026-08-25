// v149c arm -- ANONYMOUS element types: an inline struct as the queue element,
// an inline enum, and an anonymous struct VARIABLE carrying a queue.
package Ome9_pkg;
  typedef struct {
    struct { int in_a; string in_b; } inlineStructQ[$];
    enum bit [1:0] { EI_A = 2'd1, EI_B = 2'd2 } inlineEnumQ[$];
    string tailQ[$];
  } anon_elem_t;
  anon_elem_t theAnon;
endpackage

module anon_top;
  import Ome9_pkg::*;
  struct {
    string varAnonQ[$];
    int    varAnonTag;
  } varAnon;
  anon_elem_t a9;
  initial varAnon.varAnonTag = 6;
endmodule
