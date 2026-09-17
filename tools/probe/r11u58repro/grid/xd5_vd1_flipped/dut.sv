// r11u58 xd5 — vd1's BOTH-DIRECTIONS member-width law, RE-CUT INSIDE the
// flipped state: the same four member widths vd1 measured (8/16/64/32) with a
// const-function whole read added, plus a fifth member at 128 bits placed LAST
// so the producer's width bail costs nothing.  PREDICT: A 64->8, B 64->16,
// C 32->64 (WIDENS, vpiDecompile 32'd7 / DEC:7 / constType 1 preserved),
// D 64->32, and W's cast op gains vpiSize:128.
package pk;
  typedef struct packed {
    logic [7:0]   A;
    logic [15:0]  B;
    logic [63:0]  C;
    int unsigned  D;
    logic [127:0] W;
  } mix_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(mix_t c);
    r_t r;
    r.X = c.D;
    r.G = (c.A > 0);
    return r;
  endfunction
  localparam mix_t L = '{ A: 64, B: 64, C: 32'd7, D: 64, W: 128'({64'b0, 64'b0}) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::L)) (output logic [31:0] o);
  assign o = R.X;
endmodule
