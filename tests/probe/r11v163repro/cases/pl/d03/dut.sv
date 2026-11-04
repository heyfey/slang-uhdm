// § pkgPatListingCopyWhenShared163
package pk;
  typedef struct packed { logic p; logic n; } tx_t;
  parameter tx_t D = '{p: 1'b0, n: 1'b1};
  parameter tx_t E = '{p: 1'b1, n: 1'b0};
endpackage
module m import pk::*; (input tx_t [2:0] a, input tx_t [1:0] b, output logic [9:0] x);
  assign x = {a, b};
endmodule
module top(output logic [9:0] o1);
  m u(.a({3{pk::D}}), .b({2{pk::E}}), .x(o1));
endmodule
