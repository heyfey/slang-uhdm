// § memberBareTdAliasNamedByUse183 (two structs share the typedef)
package p;
typedef bit [7:0] be_t;
typedef struct { be_t x; } s1_t;
typedef struct { int n; be_t y; } s2_t;
endpackage
module top;
  import p::*;
  s1_t a;
  s2_t b;
endmodule
