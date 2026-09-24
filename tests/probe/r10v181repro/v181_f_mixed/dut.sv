// r10v181 arm F -- THE DECISIVE CELL: a call ARGUMENT and a hier_path INDEX
// BASE naming the SAME foreach loop variable in ONE EMPTYTF clone body.
//
// That is the shape in which the elaborated golden of arm B binds the two
// occurrences DIFFERENTLY (the call argument to the law cloneLoopVarShared37
// object, the index base to the loop's LISTING `ref_var`), and it is the only
// cell in which the pristine binary was right where the patched binary is not.
// Arm B's `uhdm-cmp` was masked by an earlier head; this arm is small enough
// that the judge speaks about this cell alone.
package harquebus_home;

  typedef struct packed { logic [3:0] serpentine; logic [3:0] matchcord; } culverin_t;

  class petronel_cls;
    int        petronel_arr [3];
    culverin_t petronel_structarr [3];
    extern function int falconet181_empty();
    extern function int falconet181_helper(input int touchhole);
  endclass

  function int petronel_cls::falconet181_helper(input int touchhole);
    return touchhole + 1;
  endfunction

  function int petronel_cls::falconet181_empty();
    foreach (petronel_arr[wickyard]) begin
      int caliver;
      caliver = this.falconet181_helper(wickyard);                 // call argument
      caliver = caliver + int'(petronel_structarr[wickyard].matchcord); // index base
      falconet181_empty = caliver;
    end
  endfunction

endpackage

package harquebus_imp;
  import harquebus_home::*;
  int harquebus_anchor;
endpackage

module harquebus_top;
  initial harquebus_imp::harquebus_anchor = 0;
endmodule
