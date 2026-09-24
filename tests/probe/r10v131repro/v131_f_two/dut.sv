// v131 arm F — TWO instances of the same fork-bearing module.
module Fleaf;
  int fv;
  initial begin
    fork : fNamed fv = 1; join_any : fNamed
    fork : fEmpty join_none : fEmpty
  end
endmodule
module Ftwo; Fleaf b1 (); Fleaf b2 (); endmodule
