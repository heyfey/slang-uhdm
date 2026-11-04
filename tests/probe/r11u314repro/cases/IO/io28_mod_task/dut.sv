// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int ix[4]; task t(input int k); a.v[ix[k + 1] +: 2] = 0; endtask endmodule
