// r10uvm78 arm c1 — THE HEAD'S OWN SHAPE, minimised.
//
// A SIMPLE part-select of a CLASS PROPERTY QUEUE, taken inside a CLASS METHOD,
// with a NON-CONSTANT right end.  This is `arb_sequence_q[0:b-1]` at
// uvm_sequencer_base.svh:681 (`uvm_sequence_request arb_sequence_q[$]`), the
// head of SimpleUVM/default, SimpleUVM/testflags and Scoreboard/default after
// pass 77 advanced it.
//
// The QUEUE is not decoration: IEEE 1800 requires a packed or unpacked ARRAY
// range to be constant, so a SIMPLE `[a:b]` range with a variable end is legal
// ONLY on a queue or dynamic array.  That is why the corpus population of R2 is
// exactly two queue names (`arb_sequence_q`, `string abstractions[$]`).
//
// It carries BOTH residues at once:
//   R2  vpiConstantSelect — golden stamps 1, the old both-ends gate read 0
//       because `b-1` does not evaluate.
//   R3  the bound ref `b` scopes through the select's base name, and the joint
//       between the enclosing CLASS-METHOD scope and that base name is `::` in
//       golden and was `.` in ours.
//
// Cell p2 is the NEGATIVE CONTROL for R2: both ends constant, so the flag was
// already right and must stay right.  Cell p3 is the R3 control in the OTHER
// direction: a MODULE-scope select, where the joint is a `.` in golden too and
// the law must NOT change it.
package p78c1;
  class holder;
    int q[$];
    int b;
    function void take();
      int lead[$];
      int both[$];
      b = 4;
      lead = q[0:b-1];     // p1: R2 + R3 both fire here
      both = q[0:3];       // p2: constant both ends — R2 control
    endfunction
  endclass
endpackage

module top78c1;
  int mq[$];
  int wq[$];
  int k;
  initial begin
    k = 3;
    wq = mq[0:k-1];        // p3: MODULE scope — the joint stays `.`
  end
endmodule
