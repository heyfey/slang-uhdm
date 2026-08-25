// r10uvm127 grid B — THE PASS'S OWN AXIS: OUT-OF-BODY class-method definitions
// at PACKAGE level versus IN-BODY ones.  Every stamp-bearing callee is a DPI-C
// import so the call survives the elaborated compile (see grid A's header).
// MEASUREMENT ONLY.
package Chandler;
  import "DPI-C" function int trellisPad (string bough, int girth);
  import "DPI-C" function int rafterCount(int girth, byte notch);
  import "DPI-C" function void hollowSink(string bough);

  class Meridian;
    string bough = "root";
    extern function int oobSingle  (string bough, int girth);
    extern function int oobBeginEnd(string bough, int girth);
    extern function int oobNested  (int girth, byte notch);
    extern task         oobTask    (string bough);
    // IN-BODY definitions -- the FENCE: compiled by CompileClass with
    // Reduce::No, so golden leaves the actuals bare.
    function int inBodyOne(string bough, int girth);
      return trellisPad(bough, girth);                  // bare
    endfunction
    function int inBodyTwo(int girth, byte notch);
      if (girth < 0)
        return 0;
      return rafterCount(girth, notch);                 // bare
    endfunction
  endclass

  // The definitions themselves are PACKAGE-LEVEL function declarations.
  function int Meridian::oobSingle(string bough, int girth);
    return trellisPad(bough, girth);                    // stamp
  endfunction

  function int Meridian::oobBeginEnd(string bough, int girth);
    if (girth < 0)
      return 0;
    return trellisPad(bough, girth);                    // stamp (member of the
  endfunction                                           //  synthetic begin)

  function int Meridian::oobNested(int girth, byte notch);
    if (girth > 0) begin
      return rafterCount(girth, notch);                 // bare (nested arm)
    end
    return 0;
  endfunction

  task Meridian::oobTask(string bough);
    hollowSink(bough);                                  // bare (task body)
  endtask
endpackage

module Chandler_top;
  import Chandler::*;
  Meridian holder;
  int got;
  initial begin
    holder = new();
    got = holder.oobSingle("a", 3);
  end
endmodule
