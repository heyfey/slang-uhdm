// § caFoldParentUnboundLhs267
package fp;
  localparam int AllPagesW = 9;
  typedef struct packed { logic [8:0] q; } fld_t;
  typedef struct packed { fld_t base; fld_t size; logic en; } cfg_t;
endpackage
module fc import fp::*; (output cfg_t [2:0] o, output logic [8:0] w);
  localparam int LW = 9;
  cfg_t [2:0] region_cfgs;
  cfg_t one;
  assign region_cfgs[2].size.q = {LW{1'b1}};
  assign o = region_cfgs;
endmodule
module top(output fp::cfg_t [2:0] o, output logic [8:0] w);
  fc u_fc(.o(o), .w(w));
endmodule
