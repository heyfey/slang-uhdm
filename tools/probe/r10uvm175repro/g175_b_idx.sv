// r10uvm175 arm B — the INDEX KIND written on a `with`-clause receiver step.
package bravo_yard;
  typedef enum int { SPRING = 0, SUMMER = 1 } season_e;
  localparam int PLOT = 1;
  class barrel;
    string labels[$];
    function new(); endfunction
    function int span(); return 2; endfunction
  endclass
  class shed;
    barrel casks[$];
    barrel byword[string];
    barrel grid2[4][4];
    barrel dyn[];
    barrel fixed[4];
    int found[$];
    string wanted;
    barrel picker;
    function int pick(); return 0; endfunction
    function void rummage(int cursor);
      // i_lit: an integer literal index
      found = casks[2].labels.find_index() with (item == wanted);
      // i_name: a bare name index
      found = casks[cursor].labels.find_index() with (item == wanted);
      // i_expr: a compound expression index
      found = casks[cursor + 1].labels.find_index() with (item == wanted);
      // i_str: a string-literal key on an associative array
      found = byword["north"].labels.find_index() with (item == wanted);
      // i_enum: an enum constant index
      found = casks[SUMMER].labels.find_index() with (item == wanted);
      // i_param: a package localparam index
      found = casks[PLOT].labels.find_index() with (item == wanted);
      // i_call: an index that is a CALL
      found = casks[pick()].labels.find_index() with (item == wanted);
      // i_2dim: two written dimensions on one component
      found = grid2[1][cursor].labels.find_index() with (item == wanted);
      // i_dyn: a dynamic array
      found = dyn[cursor].labels.find_index() with (item == wanted);
      // i_fix: a fixed unpacked array
      found = fixed[cursor].labels.find_index() with (item == wanted);
      // i_none: no index (the control)
      found = picker.labels.find_index() with (item == wanted);
    endfunction
  endclass
endpackage
