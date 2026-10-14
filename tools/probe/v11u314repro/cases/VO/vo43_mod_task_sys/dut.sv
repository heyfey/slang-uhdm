// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; task t(input int k); a.v[$clog2(k) +: 2] = 0; endtask endmodule
