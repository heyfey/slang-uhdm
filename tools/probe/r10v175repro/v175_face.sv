// r10v175 verifier arm F — FACES of the with-form the other arms do not carry.
package cinder_bay;
  class wedge;
    string runes[$];
    int cargo[$];
    int tick;
    function new(); endfunction
  endclass
  class vault;
    wedge crates[$];
    wedge helper;
    int caught[$];
    int total;
    string aim;
    function new(); endfunction
    function void scan(int berth, int perch);
      // f_dotidx_member: the index text carries a DOT but is a plain member
      caught = crates[helper.tick].runes.find_index() with (item == aim);
      // f_min / f_max / f_unique / f_uniqidx: other locator tails
      caught = crates[berth].cargo.min() with (item);
      caught = crates[berth].cargo.max() with (item);
      caught = crates[berth].cargo.unique() with (item);
      caught = crates[berth].cargo.unique_index() with (item);
      // f_findlast: find_last / find_last_index
      caught = crates[berth].runes.find_last_index() with (item == aim);
      // f_twocalls: TWO with-form calls in ONE expression
      total = (crates[berth].cargo.sum() with (item)) +
              (crates[perch].cargo.sum() with (item));
      // f_selfref: the with expression names the receiver's own index var
      total = crates[berth].cargo.sum() with (item + berth);
      // f_return: in a return expression
      total = tallyup(berth);
      // f_case: in a case selector
      case (crates[berth].cargo.sum() with (item))
        0: total = 0;
        default: total = 1;
      endcase
      // f_while: in a loop condition
      while ((crates[berth].cargo.sum() with (item)) > 100) total = total - 1;
    endfunction
    function int tallyup(int berth);
      return crates[berth].cargo.sum() with (item);
    endfunction
  endclass
endpackage
