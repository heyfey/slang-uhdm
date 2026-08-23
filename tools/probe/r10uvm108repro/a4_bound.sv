// r10uvm108 GRID arm 4 -- the BOUNDARY of the parens-less DOTTED form: the
// same `@handle.member;` written in every container kind, plus the shapes that
// must NOT move.  Arm 3 showed golden FENCES interface and program bodies for
// the bare form; this arm asks the same question of the dotted one.
package bd108_pkg;
  class cell108;
    event fired;
    bit   flag;
  endclass
endpackage

module bd108_top;
  import bd108_pkg::*;
  cell108 modCell;
  cell108 modArr[2];

  // f01 -- module INITIAL, dotted, module-level handle
  initial begin
    modCell = new();
    @modCell.fired;
  end

  // f02 -- module ALWAYS, dotted
  always @modCell.fired ;

  // f03 -- module task, dotted, module-level handle
  task automatic f03_modtask();
    @modCell.fired;
  endtask

  // f04 -- module task, dotted, INDEXED module-level array
  task automatic f04_modarr();
    @modArr[1].fired;
  endtask

  // f05 -- module function-scope local, dotted
  task automatic f05_loc();
    cell108 gg05; gg05 = new();
    @gg05.fired;
  endtask

  bd108_child u_child();
  bd108_iface u_if();
endmodule

module bd108_child;
  import bd108_pkg::*;
  cell108 kidCell;
  // f06 -- a CHILD instance's always, dotted
  always @kidCell.fired ;
  // f07 -- a child instance's task, dotted
  task automatic f07_kid();
    @kidCell.fired;
  endtask
endmodule

interface bd108_iface;
  import bd108_pkg::*;
  cell108 ifCell;
  // f08 -- an INTERFACE always, dotted
  always @ifCell.fired ;
  // f09 -- an interface task, dotted
  task automatic f09_iftask();
    @ifCell.fired;
  endtask
  // f10 -- an interface task's OWN local, dotted
  task automatic f10_iflocal();
    cell108 hh10; hh10 = new();
    @hh10.fired;
  endtask
endinterface

program bd108_prog;
  import bd108_pkg::*;
  cell108 progCell;
  // f11 -- a PROGRAM initial, dotted
  initial @progCell.fired;
  // f12 -- a program task's OWN local, dotted
  task automatic f12_proglocal();
    cell108 ii12; ii12 = new();
    @ii12.fired;
  endtask
endprogram

// f13 -- a $unit-scope free task's own local, dotted
task automatic f13_unitlocal();
  bd108_pkg::cell108 jj13; jj13 = new();
  @jj13.fired;
endtask
