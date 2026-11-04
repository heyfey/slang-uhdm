// § memberAliasFollowsMemberName458
typedef bit [7:0] a_t;
typedef struct { a_t addr; int k; } op_s;
module hvl_top;
  op_s s;
endmodule
module hdl_top;
  op_s s2;
endmodule
