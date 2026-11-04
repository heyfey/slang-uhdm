// § pkgNetNamedTsDimEnd280
// a wire array of an enum typedef with a logic base
package pk;
  typedef enum logic [1:0] {A, B, C} en_t;
  wire en_t w [0:1];
endpackage
module top(input pk::en_t i, output logic [1:0] o); assign o = i; endmodule
