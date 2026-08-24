// r10uvm116 arm G -- what the constraint block may REFER to: a local of the
// enclosing method, the randomize ARGUMENT itself, another class property, a
// module-level name, and a two-argument call whose block names both.  None of
// it may appear in the emitted constraint (Surelog's compileConstraintBlock
// never fills Constraint_items), so this arm is a NEGATIVE control on content.
class reader_g;
  rand int lo_g;
  rand int hi_g;
  int limit_g;
  function void span();
    int local_g;
    local_g = 4;
    if (!randomize(lo_g) with { lo_g > local_g; lo_g < limit_g; })
      limit_g = 0;
    if (!randomize(lo_g, hi_g) with { lo_g < hi_g; hi_g < limit_g + local_g; })
      limit_g = 1;
    if (!randomize(hi_g) with { hi_g inside {1, 2, 3}; })
      limit_g = 2;
  endfunction
endclass
module top_g;
  reader_g r_one;
  initial begin
    r_one = new();
    r_one.span();
  end
endmodule
