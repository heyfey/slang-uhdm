// § trailIdxStaticScopedCallName314
class item #(int W = 1); static function int sget(); return W; endfunction endclass
class holder; int idx[4]; endclass
class grid; holder h; int r; function void probe(); r = h.idx[item#()::sget()]; endfunction endclass
module top; endmodule
