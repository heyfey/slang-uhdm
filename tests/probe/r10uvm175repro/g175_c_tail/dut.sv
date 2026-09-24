// r10uvm175 arm C — the TAIL of the path: which method sits after the indexed
// receiver, `with` and without.  Includes the two neighbouring laws' own
// shapes as CONTROLS that must not move.
package charlie_dock;
  class crate;
    string manifest[$];
    int weights[$];
    rand int lot;
    function new(); endfunction
    function int heft(); return 1; endfunction
    task stow(); endtask
    constraint c_lot { lot > 0; }
  endclass
  class pier;
    crate holds[$];
    int tally[$];
    int one;
    string wanted;
    function void survey(int berth);
      // t_findidx: find_index WITH  (the head's own shape)
      tally = holds[berth].manifest.find_index() with (item == wanted);
      // t_find: find WITH
      tally = holds[berth].weights.find() with (item > 3);
      // t_first: find_first WITH
      tally = holds[berth].weights.find_first() with (item > 3);
      // t_firstidx: find_first_index WITH
      tally = holds[berth].weights.find_first_index() with (item > 3);
      // t_min: min WITH
      tally = holds[berth].weights.min() with (item);
      // t_max: max WITH
      tally = holds[berth].weights.max() with (item);
      // t_unique: unique WITH
      tally = holds[berth].weights.unique() with (item);
      // t_sum: sum WITH, in an int context
      one = holds[berth].weights.sum() with (item);
      // t_sort: a VOID array method WITH
      holds[berth].weights.sort() with (item);
      // t_nowith: the SAME receiver, NO with clause (r10uvm74's own cell)
      one = holds[berth].weights.size();
      // t_nowith2: a no-with locator over the same receiver
      tally = holds[berth].weights.min();
      // t_user: a USER method over the same receiver (deepRecvCall11's cell)
      one = holds[berth].heft();
      // t_rand: randomize WITH a constraint block (memberRandomizeWithIsRecvPath119)
      one = holds[berth].randomize() with { lot < 9; };
    endfunction
  endclass
endpackage
