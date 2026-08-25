// v149b arm -- NESTING: a queue of queues, a struct three deep each carrying
// a queue, an array of the struct, and a struct whose ONLY member is a queue.
package Gamma9_pkg;
  typedef struct { string leafQ[$]; } leaf_only_t;
  typedef struct {
    leaf_only_t midLeaf;
    int         midQ[$];
  } mid_t;
  typedef struct {
    mid_t   topMid;
    string  topQofQ[$][$];
    real    topPlain;
  } top_t;
  top_t theTop;
  leaf_only_t manyLeaves[4];
endpackage

module nested_top;
  import Gamma9_pkg::*;
  top_t t9;
  initial t9.topPlain = 2.5;
endmodule
