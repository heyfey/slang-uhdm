// § genCaReplParentBoundLhs267
package fp;
  localparam int AllPagesW = 9;
  typedef struct packed { logic [8:0] q; } fld_t;
  typedef struct packed { fld_t base; fld_t size; logic en; } cfg_t;
endpackage
module fc import fp::*; (output cfg_t [2:0] o, output logic [8:0] w, output logic [17:0] w2);
  localparam int LW = 9;
  cfg_t [2:0] region_cfgs;
  logic [8:0] a, b;
  for (genvar i = 0; i < 2; i++) begin : g
    assign region_cfgs[i].size.q = {LW{1'b1}};
  end
  assign o = region_cfgs;
endmodule
module top(output fp::cfg_t [2:0] o, output logic [8:0] w, output logic [17:0] w2);
  fc u_fc(.o(o), .w(w), .w2(w2));
endmodule
