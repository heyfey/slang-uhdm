// r10v175 verifier arm P — the POSITION a with-form call is written in.
package quill_depot;
  class ferrule;
    string tags[$];
    int mass[$];
    function new(); endfunction
  endclass
  class ledger;
    ferrule hoppers[$];
    ferrule pouch[string];
    int hits[$];
    int tally;
    string sought;
    function new(); endfunction
    function int gauge(int n); return n; endfunction
    task run(int slot);
      // p_rvalue: plain assignment rvalue
      hits = hoppers[slot].tags.find_index() with (item == sought);
      // p_arg: as a call ARGUMENT
      tally = gauge(hoppers[slot].mass.sum() with (item));
      // p_cond: inside an `if` condition
      if ((hoppers[slot].mass.sum() with (item)) > 3) tally = 1;
      // p_tern: inside a ternary
      tally = (slot > 0) ? (hoppers[slot].mass.sum() with (item)) : 0;
      // p_foreach: inside a foreach body
      foreach (hoppers[k]) begin
        hits = hoppers[k].tags.find_index() with (item == sought);
      end
      // p_repeat1 / p_repeat2 / p_repeat3: the SAME text three times
      hits = pouch["west"].tags.find_index() with (item == sought);
      hits = pouch["west"].tags.find_index() with (item == sought);
      hits = pouch["west"].tags.find_index() with (item == sought);
      // p_nowith: the same receiver with NO clause (control)
      tally = hoppers[slot].tags.size();
      // p_concat: inside a concatenation
      tally = {hoppers[slot].mass.sum() with (item)};
      // p_stmt: STATEMENT position, a void with-form sort
      hoppers[slot].mass.sort() with (item);
      // p_rand: randomize-with on an indexed receiver (neighbouring law 119)
      void'(hoppers[slot].randomize() with { 1 == 1; });
    endtask
  endclass
endpackage
