// § pkgNetNamedTsDimEnd280
// a static-qualified array and a const array of the typedef
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  static st_t v [0:1];
  const st_t c [0:2] = '{default: '0};
endpackage
module top(input pk::st_t i, output logic [3:0] o); assign o = i.a; endmodule
