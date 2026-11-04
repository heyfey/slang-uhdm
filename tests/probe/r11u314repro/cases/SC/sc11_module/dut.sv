// § trailIdxStaticScopedCallName314
class item; static function int sget(); return 0; endfunction endclass
class holder; int idx[4]; endclass
module top; holder h; int r; always_comb r = h.idx[item::sget()]; endmodule
