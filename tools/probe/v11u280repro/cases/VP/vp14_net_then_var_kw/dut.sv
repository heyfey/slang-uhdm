// § pkgNetNamedTsDimEnd280
// an implicit array then an explicit var array of the typedef (the later one a var)
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t w [0:1];
  var st_t v [0:2];
endpackage
module top(input pk::st_t i, output logic [3:0] o); assign o = i.a; endmodule
