// § trailIdxStaticScopedCallName314
class base; static function int sget(); return 0; endfunction endclass
class der extends base; endclass
class holder; int idx[4]; endclass
class grid; holder h; int r; function void probe(); r = h.idx[der::sget()]; endfunction endclass
module top; endmodule
