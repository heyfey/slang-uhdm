// § ovPkgPatOpInstanceCopy163
module test #( parameter PWR_AST_RSP = '0)();
endmodule
package pkg;
typedef struct packed {
  logic [1:0] slow_clk_val;
} pwr_ast_rsp_t;
parameter pwr_ast_rsp_t PWR_AST_RSP_DEFAULT = '{2'b01};
endpackage
module dut();
test #(.PWR_AST_RSP(pkg::PWR_AST_RSP_DEFAULT)) t();
endmodule
