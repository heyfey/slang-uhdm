// § ipsBaseOpSysRender314
`define OB i + 1
class holder; logic [7:0] v; endclass
class grid; holder h; int i; function void probe(); h.v[`OB +: 2] = 0; endfunction endclass
module top; endmodule
