// § ipsBaseOpSysRender314
`define B ia[i + 1]
class holder; logic [7:0] v; endclass
class grid; holder h; int ia[4]; int i; function void probe(); h.v[`B +: 2] = 0; endfunction endclass
module top; endmodule
