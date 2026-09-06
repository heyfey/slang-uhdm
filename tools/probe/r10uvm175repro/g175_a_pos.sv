// r10uvm175 arm A — POSITION of the written subscript in a `with`-clause
// receiver path.  Every cell is EXPRESSION position (an assignment RHS).
package alpha_box;
  class leafy;
    string tagset[$];
    int numset[$];
    function new(); endfunction
  endclass
  class midway;
    leafy stalk[$];
    string tagset[$];
    function new(); endfunction
  endclass
  class harvest;
    leafy crop[$];
    midway rows[$];
    midway lone;
    leafy solo;
    int gathered[$];
    string needle;
    function void reap(int seat, int slot);
      // p_base: subscript on component 0 only, 2 components
      gathered = crop[seat].tagset.find_index() with (item == needle);
      // p_mid: subscript on component 1 only, 3 components
      gathered = lone.stalk[slot].tagset.find_index() with (item == needle);
      // p_both: subscript on components 0 and 1
      gathered = rows[seat].stalk[slot].tagset.find_index() with (item == needle);
      // p_none: no subscript anywhere (the control)
      gathered = lone.tagset.find_index() with (item == needle);
      // p_solo: ONE component, subscripted (the array-of-queues cell)
      gathered = solo.tagset.find_index() with (item == needle);
      // p_last: subscript on the LAST component before the method
      gathered = lone.stalk[slot].numset.find_index() with (item == seat);
      // p_deep: four components, subscript on 0 and 2
      gathered = rows[seat].stalk[slot].tagset.find_index() with (item.len() == seat);
    endfunction
  endclass
endpackage
