// r10v175 verifier arm K — INDEX SPELLINGS that are not a bare decimal.
package thicket_lane;
  localparam int NOTCH = 3;
  class stave;
    string glyphs[$];
    int weights[$];
    function new(); endfunction
  endclass
  class coop;
    stave crates[8];
    stave webs[string];
    stave twoD[4][4];
    int seen[$];
    int amount;
    string goal;
    int cursorA;
    int cursorB;
    int route[4];
    function void sift();
      // k_based: a based literal index
      seen = crates[4'd2].glyphs.find_index() with (item == goal);
      // k_hex: a hex literal index
      seen = crates['h2].glyphs.find_index() with (item == goal);
      // k_space: a literal with surrounding spaces
      seen = crates[ 2 ].glyphs.find_index() with (item == goal);
      // k_param: a localparam index
      seen = crates[NOTCH].glyphs.find_index() with (item == goal);
      // k_nest: a NESTED bracket index (fence: the step must be refused)
      seen = crates[route[cursorA]].glyphs.find_index() with (item == goal);
      // k_paren: a parenthesised compound index
      seen = crates[cursorA + (cursorB)].glyphs.find_index() with (item == goal);
      // k_sum: a compound index
      amount = crates[cursorA + 1].weights.sum() with (item);
      // k_2d: two written dimensions
      amount = twoD[cursorA][cursorB].weights.sum() with (item);
      // k_str: string key
      amount = webs["hollow"].weights.sum() with (item);
      // k_cast: a cast index
      amount = crates[int'(cursorA)].weights.sum() with (item);
    endfunction
  endclass
endpackage
