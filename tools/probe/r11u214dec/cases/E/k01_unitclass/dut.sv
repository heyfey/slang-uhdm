// § importVarElemOwnName214 — a package associative array of class handles inherited by a $unit class through a $unit import (Scoreboard's uvm_random_seed_table_lookup)
package p;
  class seed_map; int s; endclass
  seed_map lookup [string];
  int plain_arr [4];
endpackage
import p::*;
class sb;
  int x;
endclass
module top;
  sb s;
endmodule
