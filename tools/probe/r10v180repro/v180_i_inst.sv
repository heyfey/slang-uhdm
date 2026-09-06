// r10v180 arm I — INSTANCE COUNT.  The same wildcard-import clone reached
// through one, two and three module instances, and a module that instantiates
// itself three times with different parameters, so the ELAB view holds three
// copies of every path the law walks.
package Girder_pk;
  typedef logic [7:0] strut_t;
  function automatic int unsigned brace_fn(strut_t load);
    strut_t held;
    held = load;
    begin
      strut_t deep;
      deep = strut_t'(held + 1);
      held = deep;
    end
    return int'(held);
  endfunction
endpackage
package Girder_imp;
  import Girder_pk::*;
endpackage
module Girder_leaf #(parameter int W = 1);
  import Girder_pk::*;
  strut_t beam;
  int unsigned out;
  initial begin
    beam = 8'(W);
    out = brace_fn(beam);
  end
endmodule
module Girder_top;
  Girder_leaf #(.W(1)) u1();
  Girder_leaf #(.W(2)) u2();
  Girder_leaf #(.W(3)) u3();
endmodule
