// § namedSlotFillerRootFile207 (typed formals of every kind skipped by a resolved named call in a class)
package p;
  typedef enum {R, G, B} col_t;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  class H; int v; endclass
  class F;
    function int m(int i, string s = "x", real r = 1.5, col_t c = G, s_t st = '0, H h = null, bit [7:0] by = 8'h5, logic l = 1'b1);
      return i;
    endfunction
    function int g(int x);
      return m(.i(x), .l(1'b0)) + m(.by(8'h1), .i(1), .c(B));
    endfunction
  endclass
endpackage
module top; endmodule
