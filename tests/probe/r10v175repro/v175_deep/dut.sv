// r10v175 verifier arm D — DEPTH: which step carries the index.
package gable_row;
  class rivet;
    string names[$];
    int loads[$];
    function new(); endfunction
  endclass
  class mast;
    rivet spars[$];
    rivet lone;
    function new(); endfunction
  endclass
  class hull;
    mast booms[$];
    mast solo;
    mast planks[4];
    int marks[$];
    int total;
    string aim;
    function void chart(int idx, int jdx);
      // d_first: index on step 0 only
      marks = booms[idx].lone.names.find_index() with (item == aim);
      // d_mid: index on step 1 only
      marks = solo.spars[jdx].names.find_index() with (item == aim);
      // d_both: index on step 0 AND step 1
      marks = booms[idx].spars[jdx].names.find_index() with (item == aim);
      // d_none: no index anywhere
      marks = solo.lone.names.find_index() with (item == aim);
      // d_last: the array the method acts on is itself the indexed step
      total = booms[idx].spars[jdx].loads.sum() with (item);
      // d_three: three components, index on the middle one
      total = solo.spars[jdx].loads.sum() with (item);
      // d_fixed: fixed array root, index on step 0
      marks = planks[idx].lone.names.find_index() with (item == aim);
    endfunction
  endclass
endpackage
