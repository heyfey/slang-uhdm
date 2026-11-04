// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; task t(input int k); begin : b int m; m = k; a.v[$clog2(m) + 1 +: 2] = 0; end endtask endmodule
