// § aliasTdMembTsInstAtAlias484 (package alias of a struct whose member is typed by an alias)
package u;
  typedef logic [3:0] n_t;
  typedef n_t n2_t;
  typedef struct packed { n2_t a; n_t b; } op_t;
  typedef op_t op2_t;
  function automatic logic [3:0] f(logic [7:0] n);
    op2_t w;
    w = n;
    return w.a;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  import u::*;
  op2_t v;
  assign v = i;
  assign o = f(v);
endmodule
