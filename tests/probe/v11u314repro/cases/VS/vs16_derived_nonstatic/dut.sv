// § trailIdxStaticScopedCallName314
class base; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; endclass
class grid extends base; holder h; int r; function void probe(); r = h.idx[base::get()]; endfunction endclass
module top; endmodule
