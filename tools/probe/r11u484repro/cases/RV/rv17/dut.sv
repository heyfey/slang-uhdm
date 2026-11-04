// § ownNamedAliasLocalIsRefVar484 (negative: an alias of a class in a package function local stays a class_var)
package u;
  class C; int k; endclass
  typedef C c2_t;
  function int f(int n);
    c2_t h;
    h = new;
    return n;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
