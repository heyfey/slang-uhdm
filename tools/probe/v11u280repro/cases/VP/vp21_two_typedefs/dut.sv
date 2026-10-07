// § pkgNetNamedTsDimEnd280
// two struct typedefs each with arrays, interleaved, and a scalar use of the first after its array
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  typedef struct packed { logic [1:0] b; } su_t;
  st_t v [0:1];
  su_t u [0:3];
  st_t w [0:2];
  st_t s;
endpackage
module top(input pk::st_t i, input pk::su_t j, output logic [3:0] o); assign o = i.a ^ j.b; endmodule
