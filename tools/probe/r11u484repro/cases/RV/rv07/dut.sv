// § ownNamedAliasLocalIsRefVar484 (package function local of an alias of an int typedef)
package u;
  typedef int i_t;
  typedef i_t i2_t;
  function int f(int n);
    i2_t v;
    v = n;
    return v;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
