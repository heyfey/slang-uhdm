// § ownNamedAliasLocalIsRefVar484 (package alias with packed dimensions on the named base)
package u;
  typedef logic [3:0] b_t;
  typedef b_t [1:0] w_t;
  function automatic logic [7:0] f(logic [7:0] n);
    w_t a;
    a = n;
    return a;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  assign o = u::f(i);
endmodule
