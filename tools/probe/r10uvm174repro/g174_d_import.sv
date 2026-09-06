// r10uvm174 arm D — THE WILDCARD-IMPORT CLONE, THE FENCE.  An importing
// package's listings carry a COPY of the home package's out-of-body class
// method; golden's copy is of the ELABORATED object and keeps the fold in
// BOTH of the importer's views.  A gate written on "am I a class-method
// clone" alone moves these cells AWAY from golden.  Golden = Surelog; both
// views.
package emberPkg;
  typedef logic [15:0] cinderWord;
  class Kindling;
    logic [23:0] sparkVec;
    extern function int gauge();
  endclass
  function int Kindling::gauge();
    return $bits(byte) + $bits(cinderWord) + $bits(sparkVec) + $bits(int);
  endfunction
  function int freeGauge();
    return $bits(byte) + $bits(cinderWord);
  endfunction
endpackage

package sootPkg;
  import emberPkg::*;
  int ashTally;
endpackage

module emberTop;
  import sootPkg::*;
  emberPkg::Kindling flareHandle;
  int cinderSink;
  initial begin
    flareHandle = new();
    cinderSink = flareHandle.gauge() + emberPkg::freeGauge();
  end
endmodule
