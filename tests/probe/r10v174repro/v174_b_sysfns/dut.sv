// r10v174repro arm B — THE CONTROL NAMES.  The patched gate is reached only
// under `name == "$bits"` (bitsKeep is consumed at ExprEmit.cpp's
// `if (name == "$bits" && !bitsKeep)`), so every OTHER type query must be
// byte-for-byte unmoved by this pass.  Three homes; queries in an order that
// shares nothing with g174_b_sysfns.sv.
package lathePkg;

  typedef logic [9:0] spindleWord;
  parameter int GRIST = 33;

  class Wicket;
    logic [4:0] tang [6];
    logic [17:0] shim;
    extern function int probeOut();
    extern task probeOutTask();
    function int probeIn();
      probeIn = $clog2(GRIST) + $size(tang) + $high(tang) + $low(tang)
              + $left(shim) + $right(shim) + $increment(tang)
              + $dimensions(tang) + $unpacked_dimensions(tang)
              + $countones(shim) + $bits(spindleWord);
    endfunction
  endclass

  // OUT-OF-BODY METHOD — the gate's own window; only $bits may move here.
  function int Wicket::probeOut();
    probeOut = $clog2(GRIST) + $size(tang) + $high(tang) + $low(tang)
             + $left(shim) + $right(shim) + $increment(tang)
             + $dimensions(tang) + $unpacked_dimensions(tang)
             + $countones(shim) + $bits(spindleWord);
  endfunction

  // OUT-OF-BODY TASK — second instance of the same window.
  task Wicket::probeOutTask();
    int gudgeon;
    gudgeon = $clog2(64) + $size(tang) + $countones(shim) + $bits(byte)
            + $dimensions(tang);
  endtask

  function automatic int freeProbe();
    logic [7:0] trundle [3];
    freeProbe = $clog2(GRIST) + $size(trundle) + $high(trundle)
              + $dimensions(trundle) + $countones(8'hA5) + $bits(byte);
  endfunction

endpackage

module latheTop; lathePkg::Wicket wk = new(); int r; initial r = wk.probeOut() + wk.probeIn() + lathePkg::freeProbe(); endmodule
