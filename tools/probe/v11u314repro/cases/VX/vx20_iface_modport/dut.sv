// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
interface ifc; a_t a; modport m(input a); endinterface
module c(ifc.m u); int k; logic [1:0] o; always_comb o = u.a.v[k + 1 +: 2]; endmodule
module top; ifc u(); c cc(.u(u)); endmodule
