// § trailIdxStaticScopedCallName314
class item; extern static function int sget(); endclass function int item::sget(); return 0; endfunction
class holder; int idx[4]; endclass
class grid; holder h; int r; function void probe(); r = h.idx[item::sget()]; endfunction endclass
module top; endmodule
