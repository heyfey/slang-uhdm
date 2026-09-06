// r10uvm174 arm C — THE HOMES.  Where a `$bits` may be written inside a
// package, and which of those homes the DEF listing owns.  Golden = Surelog;
// both views.
package lanternPkg;
  typedef logic [13:0] wickWord;

  // package parameter initializer
  parameter int GLOW = $bits(wickWord);
  // package variable initializer
  int wickTally = $bits(byte);

  class Beacon;
    // class property initializer
    int haloWidth = $bits(wickWord);
    logic [20:0] flare;

    extern function new(int seedWidth);
    extern function int outMethod();
    extern task outTask(output int sink);
    function int inMethod();
      return $bits(byte) + $bits(wickWord) + $bits(flare);
    endfunction
  endclass

  function Beacon::new(int seedWidth);
    haloWidth = seedWidth + $bits(byte) + $bits(wickWord);
  endfunction

  function int Beacon::outMethod();
    return $bits(byte) + $bits(wickWord) + $bits(flare);
  endfunction

  task Beacon::outTask(output int sink);
    sink = $bits(byte) + $bits(wickWord) + $bits(flare);
  endtask

  function int freeTorch();
    return $bits(byte) + $bits(wickWord);
  endfunction

  task freeSnuff(output int sink);
    sink = $bits(byte) + $bits(wickWord);
  endtask
endpackage

module lanternTop;
  lanternPkg::Beacon torchHandle;
  int glimSink;
  initial begin
    torchHandle = new(2);
    glimSink = torchHandle.inMethod() + torchHandle.outMethod()
             + lanternPkg::freeTorch() + lanternPkg::GLOW
             + lanternPkg::wickTally;
    torchHandle.outTask(glimSink);
    lanternPkg::freeSnuff(glimSink);
  end
endmodule
