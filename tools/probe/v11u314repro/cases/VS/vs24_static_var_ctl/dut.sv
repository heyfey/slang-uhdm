// § trailIdxStaticScopedCallName314
class item; static int sv = 1; endclass
class holder; int idx[4]; endclass
class grid; holder h; int r; function void probe(); r = h.idx[item::sv]; endfunction endclass
module top; endmodule
