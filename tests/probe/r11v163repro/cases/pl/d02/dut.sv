// § pkgPatListingCopyWhenShared163
package pk;
  typedef struct packed { logic p; logic n; } tx_t;
  parameter tx_t D = '{p: 1'b0, n: 1'b1};
endpackage
module m import pk::*; (input tx_t [2:0] a, output logic [5:0] x);
  assign x = a;
endmodule
module top(output logic [5:0] o1, o2);
  m u(.a({3{pk::D}}), .x(o1));
  m v(.a({3{pk::D}}), .x(o2));
endmodule
