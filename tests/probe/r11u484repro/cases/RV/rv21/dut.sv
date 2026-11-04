// § ownNamedAliasLocalIsRefVar484 (package task local and two declarators of a home alias)
package u;
  typedef enum { R, G, B } c_t;
  typedef c_t c2_t;
  task automatic t(output int o);
    c2_t a, b;
    a = G; b = B;
    o = int'(a) + int'(b);
  endtask
endpackage
module top;
  int x;
  initial u::t(x);
endmodule
