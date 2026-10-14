// § trailIdxStaticScopedCallName314
class item; static function int sget(); return 0; endfunction endclass
class holder; int idx[4]; endclass
class grid; holder h; int r; task probe(); r = h.idx[item::sget()]; endtask endclass
module top; endmodule
