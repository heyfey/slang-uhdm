// § ipsBaseNamesReach314
class holder; logic [7:0] v; endclass
class grid; holder h; int ia[4]; int i; function void probe(); begin : b h.v[ia[i] +: 2] = 0; end endfunction endclass
module top; endmodule
