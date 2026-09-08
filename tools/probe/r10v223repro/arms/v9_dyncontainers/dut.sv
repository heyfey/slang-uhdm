// v9 — CONTAINER SHAPES in the imported package: assoc, dynamic, queue,
// fixed unpacked, unpacked struct.  R1/R5's fate, measured on the interface
// road and the module road side by side.
package pv9;
  int aa9 [string];
  int dy9 [];
  int qu9 [$];
  int fx9 [3];
  typedef struct { int a; int b; } st9_t;
  st9_t us9 [2];
  int plain9 = 1;
endpackage

interface if_v9;
  import pv9::*;
  logic own_v9;
  int ifa9 [string];
  int ifd9 [];
  int iff9 [2];
endinterface

module m_v9;
  import pv9::*;
  logic own_mv9;
  int ma9 [string];
  int mf9 [2];
endmodule
