// r10v180 arm F — FENCE 2 UNDER PRESSURE.  A package with a class whose
// METHODS declare block locals of the package's typedef, and a free
// subroutine that touches the class from inside a clone body.  Both packages
// are in ONE design so the shared class world is reached by both routes.
package Loom_pk;
  typedef logic [8:0] warp_t;
  typedef bit   [1:0] weft_t;

  class Shuttle_c;
    warp_t held;
    function new(warp_t v); held = v; endfunction
    function automatic int unsigned pick(warp_t v);
      warp_t local_w;
      local_w = v;
      begin
        warp_t deeper;
        weft_t narrow;
        deeper = warp_t'(local_w + 1);
        narrow = weft_t'(deeper[1:0]);
        local_w = warp_t'(int'(deeper) + int'(narrow));
      end
      return int'(local_w);
    endfunction
  endclass

  function automatic int unsigned beat_fn(warp_t v);
    warp_t here;
    Shuttle_c sh;
    here = v;
    sh = new(here);
    begin
      warp_t deeper;
      weft_t narrow;
      deeper = warp_t'(here);
      narrow = weft_t'(deeper[1:0]);
      here = warp_t'(sh.pick(deeper) + int'(narrow) + int'(sh.held));
    end
    return int'(here);
  endfunction
endpackage
package Loom_imp;
  import Loom_pk::*;
endpackage
module Loom_top;
  import Loom_pk::*;
  warp_t v;
  int unsigned r;
  initial begin
    v = 9'h0f1;
    r = beat_fn(v);
  end
endmodule
