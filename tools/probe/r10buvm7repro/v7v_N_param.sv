// vbuvm7 arm N — parameterized class specializations (the CLONE path),
// always_ff, program block, unnamed block.
typedef struct { int used; } stN_t;
package pkN;
  typedef struct { int used; } sN_t;
  class cN #(int W = 1);
    sN_t arr[4];
    extern function void f();
  endclass
  function void cN::f();
    arr[W % 4].used++;         // N1 inside a PARAMETERIZED out-of-body method
  endfunction
endpackage
program prgN;
  stN_t parr[4];
  initial parr[1].used++;      // N2 inside a PROGRAM block
endprogram
module topN(input logic clk);
  import pkN::*;
  cN #(1) h1;
  cN #(2) h2;
  stN_t marr[4];
  always_ff @(posedge clk) marr[0].used++;   // N3 in always_ff
  initial begin
    h1 = new(); h2 = new(); h1.f(); h2.f();
    begin                                     // N4 unnamed block
      marr[1].used++;
    end
  end
endmodule
