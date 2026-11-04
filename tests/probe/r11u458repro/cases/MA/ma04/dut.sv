// § memberAliasFollowsMemberName458
package p;
  typedef bit [7:0] a_t;
  typedef logic [3:0] l_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; l_t ln; } op_s;
  typedef union packed { a_t x; bit [7:0] y; } u_t;
  typedef struct packed { a_t hi; a_t lo; } pk_s;
  typedef struct { pk_s w; a_t z; } nest_s;
endpackage
module hvl_top;
  import p::*;
  u_t s;
endmodule
module hdl_top;
  import p::*;
  u_t s2;
endmodule
