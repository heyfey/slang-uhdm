// r10uvm193 ARM D — THE CLASS-PROPERTY RECEIVER FENCE of
// § cloneArrayRecvArgMintsElemVar193.
//
// MEASUREMENT ONLY.  One real Surelog golden.  LHS is ALWAYS golden.
//
// Split out of arm A because Surelog itself reports `[ERR:UH0725] Unresolved
// hierarchical reference "m_hoard193.exists"` in the ELABORATED view of this
// shape — which IS the fence, stated by the producer rather than by a rule of
// ours.  `ElaboratorListener::enterTask_func` collects a CLASS's `Variables()`
// only when the task_func's `VpiParent` is a `class_defn`, and an OUT-OF-BODY
// method hoisted into the package listing has a PACKAGE parent, so the
// receiver never binds, there is no `array_var` to read, and golden hands the
// argument nothing.  D2 is the control: the SAME out-of-body method with a
// SUBROUTINE-LOCAL array binds and mints normally, so the fence is about the
// receiver's DECLARING SCOPE and not about the listing.

package Cleat193;

  class Grommet193;
    int  m_hoard193[int];
    int  m_tally193;
    extern function int d1_prop193(input int fml_d1_193);
    extern function int d2_ownarr193(input int fml_d2_193);
  endclass

  // D1  A CLASS PROPERTY associative array as the receiver, in an OUT-OF-BODY
  //     method.  `enterTask_func` collects a class's Variables() only when the
  //     task_func's VpiParent is a `class_defn`, and an out-of-body method
  //     hoisted into the package listing has a PACKAGE parent — so the
  //     receiver is BARE in the clone, there is no `array_var` to read, and
  //     golden hands the argument nothing.  This is the fence the corpus
  //     itself carries (§ 191's `bits = new[m_packed_size]`).
  function int Grommet193::d1_prop193(input int fml_d1_193);
    int kink193;
    kink193 = 5;
    if (m_hoard193.exists(kink193)) fml_d1_193 = fml_d1_193 + 1;
    return fml_d1_193 + m_tally193;
  endfunction

  // D2  The SAME out-of-body method with a SUBROUTINE-LOCAL array, the
  //     control that says the fence is about the receiver's DECLARING SCOPE
  //     and not about the listing.
  function int Grommet193::d2_ownarr193(input int fml_d2_193);
    int own193[int];
    int kink193;
    kink193 = 6;
    own193[kink193] = 2;
    if (own193.exists(kink193)) fml_d2_193 = fml_d2_193 + 1;
    return fml_d2_193;
  endfunction


endpackage

package Grapnel193;
  import Cleat193::*;
  function automatic int heave193(input int fml_m193);
    return fml_m193;
  endfunction
endpackage

module top193d;
  import Cleat193::*;
  int r193;
  initial begin
    r193 = Grapnel193::heave193(1);
  end
endmodule
