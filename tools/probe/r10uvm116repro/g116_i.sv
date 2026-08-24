// r10uvm116 arm I -- the PARENS-LESS surface.  slang binds `randomize`,
// `randomize()` and `randomize with { … }` to the SAME CallExpression; Surelog
// does not, and the difference is only in what was WRITTEN.  This arm is the
// § parensLessScopeRandomizeIsRefObj116 grid, with a comment and a newline
// wedged between the name and its parens so the probe's trivia walk is
// exercised rather than assumed.
class prober_i;
  rand int slot_i;
  int cap_i;
  function int probe();
    int r_i;
    r_i = randomize;                        // (1) parens-LESS, no with
    r_i = r_i + randomize();                // (2) parens-ful
    r_i = r_i + randomize with { slot_i > cap_i; };   // (3) parens-LESS + with
    r_i = r_i + randomize /* gap */ ();     // (4) parens after a comment
    r_i = r_i + randomize
                ();                         // (5) parens on the next line
    r_i = r_i + randomize(slot_i);          // (6) parens-ful with a name
    return r_i;
  endfunction
endclass
module top_i;
  prober_i p_one;
  int o_i;
  initial begin
    p_one = new();
    o_i = p_one.probe();
  end
endmodule
