// r10v157 ARM A — SITE 3's HOME AXIS.  A subroutine whose ENTIRE body is one
// typedef, written in every container the language allows, so "the task_func
// itself carries the listing" is tested where the implementer measured only a
// PACKAGE task and a MODULE task.  MEASUREMENT ONLY.
// Names are deliberately UNRELATED across the arm (no a_t/b_t/c_t grid).

package Quarry157;
  // package free task, sole typedef  (the implementer's soleTdTask157 twin,
  // kept as the CALIBRATION cell of this arm)
  task automatic chisel157; typedef bit [5:0] granite157; endtask
  // package free task, sole typedef, ATOM target
  task automatic mallet157; typedef shortint slate157; endtask
endpackage

class Anvil157;
  // class IN-BODY method, sole typedef
  task forge157; typedef bit [2:0] ingot157; endtask
  // class IN-BODY STATIC method, sole typedef
  static task temper157; typedef byte bellow157; endtask
  // class IN-BODY VIRTUAL method, sole typedef
  virtual task quench157; typedef logic [7:0] tongs157; endtask
  // OUT-OF-BODY declaration, defined below
  extern task hammer157;
endclass

task Anvil157::hammer157; typedef bit [9:0] scale157; endtask

interface Loom157;
  // interface task, sole typedef
  task weave157; typedef bit [4:0] shuttle157; endtask
endinterface

program Cobble157;
  // program task, sole typedef
  task stitch157; typedef bit [6:0] awl157; endtask
endprogram

module Kettle157;
  // module task, sole typedef (golden lists it TWICE — the implementer's
  // measured residue; kept so a change in that answer is visible)
  task simmer157; typedef bit [3:0] ladle157; endtask
  // module task with a PORT and a sole typedef: an ANSI port is not a body
  // item, so the count is still one
  task steep157(input int brew157); typedef bit [1:0] sieve157; endtask
  Loom157 loomInst157();
  initial begin
    // a WRITTEN begin inside a module initial — SITE 1's calibration cell
    typedef bit [11:0] kettleLocal157;
    kettleLocal157 potHold157;
    potHold157 = 0;
  end
endmodule
