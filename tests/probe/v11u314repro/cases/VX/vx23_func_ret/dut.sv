// § ipsBaseOpSysRender314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; function automatic logic [1:0] f(int k); return a.v[k + 1 +: 2]; endfunction endmodule
