// r10uvm174 arm B — THE SYSTEM FUNCTIONS.  The same out-of-body class method
// carries twelve different type-query system calls over the same operands, so
// the arm reads WHICH of them the DEF listing declines and which it never
// folded to begin with.  Golden = Surelog; both views.
package flintPkg;
  typedef logic [4:0] emberWord;

  class Splinter;
    logic [9:0] chipVec [6];
    extern function int probeAll();
    extern task probeTask(output int sink);
  endclass

  function int Splinter::probeAll();
    return $bits(byte) + $bits(emberWord) + $bits(chipVec)
         + $size(chipVec) + $clog2(64)
         + $high(chipVec) + $low(chipVec)
         + $left(chipVec) + $right(chipVec)
         + $increment(chipVec) + $dimensions(chipVec)
         + $unpacked_dimensions(chipVec) + $countones(4'b1011);
  endfunction

  task Splinter::probeTask(output int sink);
    sink = $bits(byte) + $size(chipVec) + $clog2(32) + $bits(emberWord);
  endtask
endpackage

module flintTop;
  flintPkg::Splinter shardHandle;
  int emberSink;
  initial begin
    shardHandle = new();
    emberSink = shardHandle.probeAll();
    shardHandle.probeTask(emberSink);
  end
endmodule
