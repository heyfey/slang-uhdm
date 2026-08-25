// r10uvm147 VERIFIER grid X — the last faces: FOUR element steps, a NONBLOCKING
// lvalue, an assertion property, a for-loop header, $bits/$cast arguments, a
// packed-array member with a parameterized width, and a queue element receiver.
package q147vx;
  class cx147 #(int W = 32);
    logic [W-1:0] d4[2][2][2][2];
    logic [W-1:0] d1[4];
    logic [W-1:0] pk;
  endclass
  typedef struct { logic [31:0] a[4]; } sx147_t;

  class ux147;
    cx147#(32) prop;
    function void g(cx147#(32) fa, sx147_t fs, int a, int b, int c, int d, int i);
      logic [7:0] o;
      int n;
      o = fa.d4[a][b][c][d][8*i +: 8];     // x01 FOUR element steps + range
      o = fa.d4[a][b][c][d][8*i+7 -: 8];   // x02 four steps, -:
      n = $bits(fa.d1[a][8*i +: 8]);       // x03 $bits argument
      for (int k = fa.d1[a][8*i +: 8]; k < 4; k++) o = 8'h1;  // x04 for-init
      o = fs.a[a][8*i +: 8];               // x05 struct formal, param width
    endfunction
    task tk(cx147#(32) fa, int a, int i);
      fa.d1[a][8*i +: 8] <= 8'h2;          // x06 NONBLOCKING lvalue, formal
      prop.d1[a][8*i +: 8] <= 8'h3;        // x07 NONBLOCKING lvalue, property
    endtask
    // controls on a LOCAL VARIABLE receiver
    function void gctl(int a, int b, int c, int d, int i);
      cx147#(32) lv;
      logic [7:0] o;
      o = lv.d4[a][b][c][d][8*i +: 8];     // x21
      o = lv.d1[a][8*i +: 8];              // x22
    endfunction
  endclass
endpackage

module m147x (input logic clk);
  import q147vx::*;
  cx147#(32) mh;
  sx147_t ms;
  int a, i;
  logic [7:0] o;
  always_ff @(posedge clk) mh.d1[a][8*i +: 8] <= 8'h4;   // x08 always_ff NB lvalue
  always_comb o = ms.a[a][8*i +: 8];                     // x09 always_comb rvalue
  initial begin
    for (int k = 0; k < 4; k++) o = ms.a[k][8*i +: 8];   // x10 loop-var index
  end
  assert property (@(posedge clk) ms.a[a][8*i +: 8] == 8'h0);  // x11 assertion
endmodule
