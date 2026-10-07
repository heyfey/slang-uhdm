// § pkgNetNamedTsDimEnd280
// an array with an initializer and a multi-line declaration
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v
    [0:1] = '{default: '0};
endpackage
module top(output logic [3:0] o); assign o = pk::v[1].a; endmodule
