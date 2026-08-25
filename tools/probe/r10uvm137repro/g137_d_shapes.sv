// r10uvm137 arm D — HOMES OF THE OUTER ARRAY that arm C left open, plus the
// SHAPE dimensions: loop-list arity, skipped slots, dotted DEPTH, nesting and
// repeats.  MEASUREMENT ONLY.
package kiln137;
  typedef class Shard137;
  class Vessel137;
    bit pores137[Shard137];
    int glaze137[string];
  endclass
  class Shard137;
    bit cracks137[Shard137];
    Vessel137 jar137;
    int grid137[3][4];
  endclass
endpackage

interface ifd137;
  import kiln137::*;
  bit    id_a137[Shard137];        // INTERFACE-LEVEL variable, bit element
  Shard137 id_b137[Shard137];      // INTERFACE-LEVEL variable, class element
  int    tick137;
  function automatic void spin137();
    foreach (id_a137[d1]) foreach (d1.cracks137[d2]) tick137++;
    foreach (id_b137[d3]) foreach (d3.cracks137[d4]) tick137++;
  endfunction
endinterface

package vault137;
  import kiln137::*;
  class Depot137;
    static bit sd_a137[Shard137];     // STATIC class property, bit element
    bit        nd_a137[Shard137];     // NON-static class property, bit element
    extern static function int drain137();
    extern function int rinse137(ref bit fd_a137[Shard137]);
  endclass

  function int Depot137::drain137();
    int tick137;
    foreach (sd_a137[d5]) foreach (d5.cracks137[d6]) tick137++;
    return tick137;
  endfunction

  function int Depot137::rinse137(ref bit fd_a137[Shard137]);
    int tick137;
    // SHAPE: dotted DEPTH 3 off a failing base
    foreach (fd_a137[d7]) foreach (d7.jar137.pores137[d8]) tick137++;
    // SHAPE: dotted DEPTH 3 off a RESOLVING base (a local handle)
    begin
      Shard137 pin137;
      foreach (pin137.jar137.pores137[d9]) tick137++;
    end
    // SHAPE: TWO named loop vars on a 2-D member off a failing base
    foreach (fd_a137[da]) foreach (da.grid137[db,dc]) tick137++;
    // SHAPE: LEADING skipped slot
    foreach (fd_a137[dd]) foreach (dd.grid137[,de]) tick137++;
    // SHAPE: TRAILING skipped slot
    foreach (fd_a137[df]) foreach (df.grid137[dg,]) tick137++;
    // SHAPE: the failing base NESTED one deeper
    foreach (fd_a137[dk])
      foreach (dk.cracks137[dl])
        foreach (dl.cracks137[dm]) tick137++;
    // SHAPE: the SAME text three times in one subroutine
    foreach (fd_a137[dn]) foreach (dn.cracks137[dp]) tick137++;
    foreach (fd_a137[dq]) foreach (dq.cracks137[dr]) tick137++;
    foreach (fd_a137[ds]) foreach (ds.cracks137[dt]) tick137++;
    // CONTRAST: the non-static class property as the outer array
    foreach (nd_a137[du]) foreach (du.cracks137[dv]) tick137++;
    return tick137;
  endfunction
endpackage

module topd137(input logic clk137);
  import kiln137::*;
  import vault137::*;
  ifd137 pipe137();
  bit      mv_a137[Shard137];      // MODULE-LEVEL variable, bit element
  bit      mv_b137[Shard137];
  int      tick137;
  Depot137 keep137;
  initial begin
    keep137 = new();
    tick137 = keep137.rinse137(mv_b137);
    tick137 += Depot137::drain137();
  end
  task automatic ream137();
    foreach (mv_a137[dw]) foreach (dw.cracks137[dx]) tick137++;
  endtask
  always @(posedge clk137) begin
    foreach (mv_a137[dy]) foreach (dy.cracks137[dz]) tick137++;
  end
  if (1) begin : gen137
    bit gv_a137[Shard137];         // GENERATE-BLOCK variable, bit element
    int gtick137;
    always @(posedge clk137) begin
      foreach (gv_a137[e1]) foreach (e1.cracks137[e2]) gtick137++;
    end
  end
endmodule
