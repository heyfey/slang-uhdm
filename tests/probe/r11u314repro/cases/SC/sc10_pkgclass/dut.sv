// § trailIdxStaticScopedCallName314
package q; class item; static function int sget(); return 0; endfunction endclass endpackage
class holder; int idx[4]; endclass
class grid; holder h; int r; function void probe(); r = h.idx[q::item::sget()]; endfunction endclass
module top; endmodule
