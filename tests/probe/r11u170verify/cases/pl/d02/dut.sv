// § pkgPatListingCopyWhenShared163
package pk;
  typedef struct packed { logic p; logic n; } tx_t;
  parameter tx_t D = '{p: 1'b0, n: 1'b1};
endpackage
module sub (input logic [5:0] a, input logic [3:0] b, output logic [9:0] o); assign o = {a, b}; endmodule
module top (output logic [9:0] o);
  sub u(.a({3{pk::D}}), .b({2{pk::D}}), .o(o));
endmodule
