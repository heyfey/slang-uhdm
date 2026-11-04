// § caFoldParentUnboundLhs267
package fp;
  localparam int AllPagesW = 9;
  typedef struct packed { logic [8:0] q; } fld_t;
  typedef struct packed { fld_t base; fld_t size; logic en; } cfg_t;
endpackage
module fc import fp::*; (output cfg_t [2:0] o);
  cfg_t [2:0] region_cfgs;
  assign region_cfgs[2].base.q = '0;
  assign region_cfgs[2].size.q = {AllPagesW{1'b1}};
  assign region_cfgs[2].en = 1'b1;
  assign o = region_cfgs;
endmodule
module top(output fp::cfg_t [2:0] o);
  fc u_fc(.o(o));
endmodule
