// § trailIdxStaticScopedCallName314
class item; static function int sget(); return 0; endfunction endclass
typedef struct packed { logic [3:0] [7:0] idx; } ps_t;
module top; ps_t h; logic [7:0] r; always_comb r = h.idx[item::sget()]; endmodule
