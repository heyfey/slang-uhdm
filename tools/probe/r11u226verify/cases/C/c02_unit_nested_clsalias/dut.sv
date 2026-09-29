// § classTdAliasLastWriter214 — the aliased specialization typedef imported into $unit and held by a class nested inside a $unit class
package p;
  class box #(type T = int); T v; endclass
  typedef box #(byte) bbox_t;
  typedef box #(byte) bbox2_t;
endpackage
import p::*;
class outer_c;
  class inner_c;
    bbox2_t h;
  endclass
endclass
module top;
endmodule
