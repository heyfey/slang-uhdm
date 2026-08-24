// r10uvm116 arm D -- control positions for the scope form: while, ternary,
// a void'() cast, a plain expression, and a with-block that reads a LOCAL of
// the enclosing method, the ARGUMENT itself and another class PROPERTY.
class walker_d;
  rand int step_d;
  int bound_d;
  int guard_d;
  function void march();
    int local_cap;
    local_cap = 9;
    while (!randomize(step_d) with { step_d < local_cap; step_d > bound_d; })
      guard_d = guard_d + 1;
    guard_d = randomize(step_d) ? 1 : 2;
    void'(randomize(step_d) with { step_d != guard_d; });
  endfunction
endclass
module top_d;
  walker_d w_one;
  initial begin
    w_one = new();
    w_one.march();
  end
endmodule
