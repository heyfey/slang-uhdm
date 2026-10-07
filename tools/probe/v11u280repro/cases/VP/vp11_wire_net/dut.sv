// § pkgNetNamedTsDimEnd280
// a wire array and a var array of a union typedef, then a later var of the typedef
package pk;
  typedef union packed { logic [3:0] a; logic [3:0] b; } un_t;
  wire un_t wv [0:1];
  var un_t vv [0:2];
  un_t s;
endpackage
module top(output logic [3:0] o); assign o = pk::s.a; endmodule
