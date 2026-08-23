// r10uvm108 GRID arm 2 -- the CONTEXTS an event control can sit in.  Each cell
// reads a SUBROUTINE-LOCAL or a FORMAL (the only two symbol classes arm 1
// showed golden ever binding) from a different statement position / carrier /
// home, so the axis under test is the POSITION and never the symbol.
package cx108_pkg;

  class node108;
    event fired;
  endclass

  class ctx108;
    bit guard;

    // d01 -- top level of an in-body task (the control, = arm 1 c01)
    task automatic d01_top();
      node108 aa01; aa01 = new();
      @aa01.fired;
    endtask

    // d02 -- inside an UNNAMED begin/end
    task automatic d02_begin();
      node108 bb02; bb02 = new();
      begin
        @bb02.fired;
      end
    endtask

    // d03 -- inside a NAMED begin, reading the TASK's local
    task automatic d03_named();
      node108 cc03; cc03 = new();
      begin : lbl03
        @cc03.fired;
      end
    endtask

    // d04 -- inside a NAMED begin, reading the NAMED BLOCK's OWN local
    task automatic d04_namedown();
      begin : lbl04
        node108 dd04; dd04 = new();
        @dd04.fired;
      end
    endtask

    // d05 -- inside an UNNAMED begin, reading that block's OWN local
    task automatic d05_beginown();
      begin
        node108 ee05; ee05 = new();
        @ee05.fired;
      end
    endtask

    // d06 -- one IF body deep
    task automatic d06_if();
      node108 ff06; ff06 = new();
      if (guard)
        @ff06.fired;
    endtask

    // d07 -- one FOREVER body deep
    task automatic d07_forever();
      node108 gg07; gg07 = new();
      forever
        @gg07.fired;
    endtask

    // d08 -- one FOR body deep
    task automatic d08_for();
      node108 hh08; hh08 = new();
      for (int i08 = 0; i08 < 2; i08++)
        @hh08.fired;
    endtask

    // d09 -- inside a CASE item
    task automatic d09_case();
      node108 ii09; ii09 = new();
      case (guard)
        1'b1: @ii09.fired;
        default: ;
      endcase
    endtask

    // d10 -- inside a fork ... join arm
    task automatic d10_fork();
      node108 jj10; jj10 = new();
      fork
        @jj10.fired;
      join
    endtask

    // d11 -- under a DELAY carrier (`#1 @x.e;`)
    task automatic d11_delay();
      node108 kk11; kk11 = new();
      #1 @kk11.fired;
    endtask

    // d12 -- under a WAIT-statement carrier
    task automatic d12_waitcar();
      node108 ll12; ll12 = new();
      wait (guard) @ll12.fired;
    endtask

    // d13 -- under ANOTHER event control
    task automatic d13_evcar();
      node108 mm13;
      event pre13;
      mm13 = new();
      @pre13 @mm13.fired;
    endtask

    // d14 -- a STATIC method (the corpus shape: wait_modified is `static task`)
    static task d14_static();
      node108 nn14; nn14 = new();
      @nn14.fired;
    endtask

    // d15 -- a non-automatic (default lifetime) task
    task d15_plain();
      node108 oo15; oo15 = new();
      @oo15.fired;
    endtask

    // d16 -- an out-of-body task, declared here
    extern task d16_oob();

    // d17 -- the read AFTER a blocking assignment to the same handle
    task automatic d17_afterassign();
      node108 pp17;
      pp17 = new();
      pp17 = new();
      @pp17.fired;
    endtask

    // d18 -- two event controls in one body (the SECOND one)
    task automatic d18_second();
      node108 qq18;
      event  rr18;
      qq18 = new();
      @rr18;
      @qq18.fired;
    endtask
  endclass

  task automatic d16_free();          // d19 -- a PACKAGE FREE task
    node108 ss19; ss19 = new();
    @ss19.fired;
  endtask

  task ctx108::d16_oob();
    node108 tt16; tt16 = new();
    @tt16.fired;
  endtask
endpackage

module cx108_top;
  import cx108_pkg::*;
  node108 uu20;
  event   vv21;
  logic   ww22;

  // d20 -- a module INITIAL block reading a module-level class handle
  initial begin
    uu20 = new();
    @uu20.fired;
  end

  // d21 -- a module initial reading a module-level event
  initial begin
    @vv21;
  end

  // d22 -- a module ALWAYS reading a module-level variable
  always @(ww22) ww22 = ~ww22;

  // d23 -- a task INSIDE the module reading its own local
  task automatic d23_modtask();
    node108 xx23; xx23 = new();
    @xx23.fired;
  endtask
endmodule
