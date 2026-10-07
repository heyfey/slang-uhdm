// § pkgNetNamedTsDimEnd280
// a package parameter of the typedef beside the array, and a package function returning it
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  parameter st_t P = '{a: 4'h3};
  st_t v [0:1];
  function automatic st_t f(); return P; endfunction
endpackage
module top(output logic [3:0] o); assign o = pk::f().a ^ pk::P.a; endmodule
