// § trailIdxStaticScopedCallName314
class base; static function int sget(); return 0; endfunction endclass
class holder; int idx[4]; endclass
class grid extends base; holder h; int r; function void probe(); r = h.idx[base::sget()]; endfunction endclass
module top; endmodule
