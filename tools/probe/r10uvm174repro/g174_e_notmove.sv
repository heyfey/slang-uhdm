// r10uvm174 arm E — THE NEGATIVE CONTROL.  A class declared in a MODULE, a
// $unit-scope subroutine, an interface and a plain module body: none of them
// is a package DEF listing, so no cell here may move.  Golden = Surelog; both
// views.
typedef logic [18:0] unitWord;

function automatic int unitGauge();
  return $bits(byte) + $bits(unitWord);
endfunction

interface pulleyIf;
  logic [10:0] ropeVec;
  function automatic int ropeGauge();
    return $bits(byte) + $bits(ropeVec);
  endfunction
endinterface

module winchTop;
  typedef logic [7:0] drumWord;

  class Capstan;
    logic [12:0] chainVec;
    extern function int haul();
    function int heave();
      return $bits(byte) + $bits(drumWord) + $bits(chainVec);
    endfunction
  endclass

  function int Capstan::haul();
    return $bits(byte) + $bits(drumWord) + $bits(chainVec);
  endfunction

  function int modGauge();
    return $bits(byte) + $bits(drumWord);
  endfunction

  Capstan gearHandle;
  pulleyIf ropeIf();
  int haulSink;
  initial begin
    gearHandle = new();
    haulSink = gearHandle.heave() + gearHandle.haul() + modGauge()
             + unitGauge() + ropeIf.ropeGauge();
  end
endmodule
