// § ovPkgPatOpInstanceCopy163
module test #( parameter PWR_AST_RSP = '0)(output logic [1:0] o);
  assign o = PWR_AST_RSP;
endmodule
package pkg;
typedef struct packed {
  logic [1:0] slow_clk_val;
} pwr_ast_rsp_t;
parameter pwr_ast_rsp_t PWR_AST_RSP_DEFAULT = '{
  slow_clk_val: 2'b10
};
endpackage
module dut(output logic [1:0] o);
test #(.PWR_AST_RSP(pkg::PWR_AST_RSP_DEFAULT)) t(.o(o));
endmodule
