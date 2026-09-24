// § packedArrTdElemRefName137
// case pd06: a package packed-array enum typedef as a sub-module localparam type
package ep6;
  typedef enum logic [1:0] {K0, K1, K2} k_t;
  typedef k_t [1:0] ka_t;
endpackage
module top(output logic [3:0] o);
  localparam ep6::ka_t INIT = {ep6::K1, ep6::K2};
  assign o = INIT;
endmodule
