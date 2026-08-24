// r10uvm116 arm F -- the PARENT of the with-constraint in five different
// expression positions: under a unary !, bare in an if condition, on the RHS
// of an assignment, inside a while, and as a ternary condition.  Surelog's
// compileConstraintBlock sets VpiParent(pexpr) and nothing else, so this arm
// is what says WHICH object pexpr is at each position.
class picker_f;
  rand int slot_f;
  int cap_f;
  int hit_f;
  function void one();
    if (!randomize(slot_f) with { slot_f < cap_f; })
      hit_f = 1;
  endfunction
  function void two();
    if (randomize(slot_f) with { slot_f > cap_f; })
      hit_f = 2;
  endfunction
  function void three();
    hit_f = randomize(slot_f) with { slot_f == cap_f; };
  endfunction
  function void four();
    while (!randomize(slot_f) with { slot_f != cap_f; })
      hit_f = hit_f + 1;
  endfunction
  function void five();
    hit_f = randomize(slot_f) with { slot_f > 0; } ? 7 : 8;
  endfunction
endclass
module top_f;
  picker_f p_one;
  initial begin
    p_one = new();
    p_one.one();
  end
endmodule
