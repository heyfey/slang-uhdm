// r10uvm116 arm E -- the NEGATIVE control.  A user function literally NAMED
// `randomize` (in a package, not a class) called with one argument, plus a
// user CLASS named `randomize_e` with a member of that name; nothing here is
// the built-in, and none of it may move.
package pkg_e;
  function automatic int randomize(int seed_e);
    randomize = seed_e + 1;
  endfunction
endpackage
class box_e;
  int val_e;
  function int bump_e(int seed_e);
    bump_e = pkg_e::randomize(seed_e);
  endfunction
endclass
module top_e;
  import pkg_e::*;
  box_e b_one;
  int r_e;
  int seed_e;
  initial begin
    b_one = new();
    r_e = randomize(seed_e);
    r_e = b_one.bump_e(2);
  end
endmodule
