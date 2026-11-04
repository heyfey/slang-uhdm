// § importVarElemOwnName214 — a package associative array of a struct keyed by string and a fixed array of int, inherited by a $unit class through a $unit import
package p;
  typedef struct { int a; byte b; } rec_t;
  rec_t table_lookup [string];
  int fixed_tab [4];
endpackage
import p::*;
class holder_c;
  int z;
endclass
module top;
endmodule
