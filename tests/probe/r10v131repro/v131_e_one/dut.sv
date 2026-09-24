// v131 arm E — ONE instance of the fork-bearing module (multiplicity control).
module Eleaf;
  int ev;
  initial begin
    fork : eNamed ev = 1; join_none : eNamed
    fork : eEmpty join : eEmpty
  end
endmodule
module Eone; Eleaf a1 (); endmodule
