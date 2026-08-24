// v116 arm X -- the parens-LESS randomize reached through a MACRO, where the
// probe's trivia window reads the macro DEFINITION site rather than the
// invocation.  If methodParensWritten77's conservative default (PARENS-FUL)
// misfires for scopeRandomizeCall116, this arm shows it.
`define BARE randomize
`define BARE_TRAIL randomize   /* trailing comment, no newline after */
class prober_x;
  rand int slot_x;
  int cap_x;
  function int probe();
    int r_x;
    r_x = `BARE;
    r_x = r_x + `BARE_TRAIL;
    r_x = r_x + `BARE();
    r_x = r_x + randomize;
    return r_x;
  endfunction
endclass
module top_x;
  prober_x p_one;
  int o_x;
  initial begin
    p_one = new();
    o_x = p_one.probe();
  end
endmodule
