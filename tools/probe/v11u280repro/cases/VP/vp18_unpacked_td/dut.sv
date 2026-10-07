// § pkgNetNamedTsDimEnd280
// an unpacked-array typedef of the struct as the element of a further unpacked array
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  typedef st_t arr_t [0:1];
  arr_t v [0:2];
endpackage
module top(input pk::st_t i, output logic [3:0] o); assign o = i.a; endmodule
