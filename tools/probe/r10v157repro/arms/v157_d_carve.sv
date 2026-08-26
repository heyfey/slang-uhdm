// r10v157 ARM D — THE CARVE-OUTS, PUSHED.  The two places this law refuses to
// list (a CONSTRUCTOR and the TF-ITEM production) are written in more shapes
// than the implementer's d_sub used, together with the shapes that must still
// list right next to them.  MEASUREMENT ONLY.

// a $unit-scope (compilation unit) task with a sole typedef
task automatic driftUnit157; typedef bit [3:0] siltGrain157; endtask

package Estuary157;
  class Tide157;
    int level157;
    // CONSTRUCTOR, sole typedef
    function new(); typedef bit [2:0] ebbMark157; level157 = 0; endfunction
  endclass

  class Surge157 extends Tide157;
    // CONSTRUCTOR with super.new and a WRITTEN begin holding a typedef
    function new();
      super.new();
      begin : d_ctorblock157
        typedef bit [6:0] crestMark157;
        crestMark157 crestHold157;
        crestHold157 = 0;
      end
    endfunction
    // a NON-constructor method of the SAME class, right next to it, which
    // MUST still list — proves the ctor gate is not leaking to its siblings
    task swell157;
      begin : d_siblingblock157
        typedef bit [4:0] wakeMark157;
        wakeMark157 wakeHold157;
        wakeHold157 = 0;
      end
    endtask
  endclass

  // TF-ITEM production: a non-ANSI port declaration written in the BODY
  task automatic dredge157;
    input int scoopIn157;
    typedef bit [5:0] scowPlank157;      // compiled by NOBODY in golden
    scoopIn157 = 0;
  endtask

  // the ANSI twin of the same task — MUST list
  task automatic barge157(input int scoopIn157);
    typedef bit [5:0] scowPlank157;
    scoopIn157 = 0;
  endtask

  // TF-ITEM production with a NESTED WRITTEN begin: the nested block is a
  // statement, so `compileStmt` reaches it and golden DOES list there
  task automatic ferry157;
    input int hullIn157;
    begin : d_tfitemblock157
      typedef bit [7:0] keelPlank157;
      keelPlank157 keelHold157;
      keelHold157 = 0;
    end
  endtask

  // ANSI ports of every direction with a sole typedef body
  task automatic sluice157(input int inFlow157, output int outFlow157,
                           inout int bothFlow157, ref int refFlow157);
    typedef bit [9:0] gateSlat157;
  endtask
endpackage

module Harbor157;
  // a class declared INSIDE a module, with a listing method
  class Buoy157;
    function int bob157();
      typedef bit [8:0] ropeTwist157;
      ropeTwist157 twistHold157;
      twistHold157 = 0;
      return int'(twistHold157);
    endfunction
  endclass
  Buoy157 markerOne157;
  initial begin
    markerOne157 = new();
    void'(markerOne157.bob157());
  end
endmodule
