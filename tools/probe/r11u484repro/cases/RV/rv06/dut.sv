// § ownNamedAliasLocalIsRefVar484 (package function local of an alias of a vector typedef)
package u;
  typedef logic [3:0] w_t;
  typedef w_t w2_t;
  function int f(int n);
    w2_t v;
    v = n;
    return v;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
