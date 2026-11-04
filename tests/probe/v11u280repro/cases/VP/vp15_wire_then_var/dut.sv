// § pkgNetNamedTsDimEnd280
// a wire array then an implicit array of a union typedef
package pk;
  typedef union packed { logic [3:0] a; logic [3:0] b; } un_t;
  wire un_t wv [0:1];
  un_t s [0:2];
endpackage
module top(input pk::un_t i, output logic [3:0] o); assign o = i.a; endmodule
