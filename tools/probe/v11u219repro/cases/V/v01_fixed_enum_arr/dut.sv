// § importVarElemOwnName214 — package fixed-size and dynamic arrays of an enum and of a struct, inherited by a $unit class and a package class
package p;
  typedef enum logic [1:0] {Z0, Z1} z_t;
  typedef struct { int a; } st_t;
  z_t zarr [3];
  st_t sdyn [];
  class holder; int h; endclass
  holder hq [$];
endpackage
package q;
  import p::*;
  class qc; int y; endclass
endpackage
import p::*;
class uc;
  int x;
endclass
module top;
  uc u;
endmodule
