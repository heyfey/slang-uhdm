// § pkgNetNamedTsDimEnd280
// the stretched typedef also typing a module variable, a module net and a function formal
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } st_t;
  st_t v [0:1];
  function automatic logic [7:0] fa(st_t x); return x.a; endfunction
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  pk::st_t m;
  wire pk::st_t n = '0;
  assign m = {i, i};
  assign o = pk::fa(m) ^ n.b;
endmodule
