// § trailIdxStaticScopedCallName314
class item; static function int sget(); return 0; endfunction endclass
class holder; int idx[4]; endclass
module top; holder h; task t(); h.idx[item::sget()] = 0; endtask endmodule
