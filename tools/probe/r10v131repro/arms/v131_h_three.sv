// v131 arm H — THREE instances of a fork-bearing module, plus a submodule chain.
module Hleaf #(parameter int TAG = 0);
  int hv;
  initial begin
    fork : hNamed hv = TAG; join_none : hNamed
    fork : hEmpty join_any : hEmpty
    fork hv = TAG + 1; join
  end
endmodule
module Hmid; Hleaf #(.TAG(7)) m1 (); endmodule
module Hthree;
  Hleaf #(.TAG(1)) t1 ();
  Hleaf #(.TAG(2)) t2 ();
  Hleaf #(.TAG(3)) t3 ();
  Hmid            t4 ();
endmodule
