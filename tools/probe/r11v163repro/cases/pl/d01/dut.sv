// § pkgPatListingCopyWhenShared163
package pk;
  typedef struct packed { logic p; logic n; } tx_t;
  parameter tx_t D = '{p: 1'b0, n: 1'b1};
endpackage
module m import pk::*; (input tx_t [1:0] a, output logic [3:0] x);
  assign x = a;
endmodule
module top(output logic [3:0] o);
  m u(.a({pk::D, pk::D}), .x(o));
endmodule
