// § pkgNetNamedTsDimEnd280
// an explicit var array of the struct typedef only
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  var st_t v [0:1];
endpackage
module top(input pk::st_t i, output logic [3:0] o); assign o = i.a; endmodule
