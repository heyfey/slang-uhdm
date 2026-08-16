// r10uvm77 arm c1 — the CORPUS SHAPE reduced: a parens-less BUILT-IN CLASS
// method (`process::status`) as the TRAILING step of a dotted hier_path.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The head this pass owns is uvm_sequencer_base.svh:664:
//     q = arb_sequence_q.find(item) with (item.request==SEQ_TYPE_LOCK &&
//         item.process_id.status inside {process::KILLED,process::FINISHED});
// Cell w3 is that statement, name for name.
//
// Every cell is ONE SOURCE SITE keyed on the method token's line:col.

class req77;
  process process_id;
  int     request;
endclass

module top77c1;
  req77   arb[$];
  req77   qq[$];
  process p;
  int     r;

  function int f77;
    // p1: TWO-step path, parens-LESS, plain rvalue.  THE WITNESS.
    if (p.status == process::KILLED)
      r = 1;
    // p2: the identical reference WITH EMPTY PARENS.  POSITIVE CONTROL —
    //     must stay a method_func_call on both sides.
    if (p.status() == process::FINISHED)
      r = 2;
    // p3: a DIFFERENT process built-in, parens-less.
    if (p.status == process::WAITING)
      r = 3;
    // w3: the CORPUS SHAPE — three steps, trailing built-in, inside a
    //     `with` clause on an array-locator method.
    qq = arb.find(item) with (item.process_id.status inside {process::KILLED,
                                                            process::FINISHED});
    return r;
  endfunction
endmodule
