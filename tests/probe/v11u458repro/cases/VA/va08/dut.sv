// § memberAliasFollowsMemberName458
package p;
  typedef bit [7:0] a_t;
  typedef struct { a_t addr; } op_s;
  typedef struct { a_t lo; a_t hi; } rg_s;
endpackage
module mm;
  import p::*;
  rg_s r;
  op_s s;
endmodule
module zz;
  import p::*;
  op_s s;
endmodule
module aa;
  import p::*;
  rg_s r;
endmodule
