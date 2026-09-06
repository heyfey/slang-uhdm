// r10v174repro arm F — THE EDGE FACES the width rules refuse, in the gate's
// own window: a class HANDLE, a string, a chandle, an event, a queue, a
// dynamic array, an associative array, a real, a realtime.  These are the
// faces § bitsSelectIgnoredRootBits95 gives NO width, so pristine already
// kept most of them; the gate must not turn any of them into a fold, and must
// not lose the ones already kept.
package cistern_pkg;

  typedef logic [7:0] SluiceWord;

  class Weir;
    Weir        gate3;
    string      motto;
    chandle     hasp;
    event       trip;
    int         q1 [$];
    byte        dyn1 [];
    int         assoc1 [string];
    real        depth;
    realtime    span;
    SluiceWord  pool [3];
    extern function int edgeOut();
    function int edgeIn();
      edgeIn = $bits(motto) + $bits(q1) + $bits(dyn1) + $bits(depth)
             + $bits(span) + $bits(pool) + $bits(pool[1]);
    endfunction
  endclass

  function int Weir::edgeOut();
    edgeOut = $bits(motto) + $bits(q1) + $bits(dyn1) + $bits(depth)
            + $bits(span) + $bits(pool) + $bits(pool[1]);
  endfunction

endpackage

module cisternTop; cistern_pkg::Weir wr = new(); int r; initial r = wr.edgeOut() + wr.edgeIn(); endmodule
