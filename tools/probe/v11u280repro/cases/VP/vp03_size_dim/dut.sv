// § pkgNetNamedTsDimEnd280
// size-form dimensions [4] and [N] with N a package parameter
package pk;
  parameter int N = 3;
  typedef struct packed { logic [3:0] a; } st_t;
  typedef struct packed { logic [1:0] b; } su_t;
  st_t v [4];
  su_t u [N];
endpackage
module top(output logic [3:0] o); assign o = pk::v[0].a; endmodule
