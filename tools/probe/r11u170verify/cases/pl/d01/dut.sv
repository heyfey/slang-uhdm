// § pkgPatListingCopyWhenShared163
package pk;
  typedef struct packed { logic p; logic n; } tx_t;
  parameter tx_t D = '{p: 1'b0, n: 1'b1};
endpackage
module sub (input logic [7:0] a, output logic [7:0] o); assign o = a; endmodule
module top (output logic [7:0] o);
  sub u(.a({pk::D, {3{pk::D}}}), .o(o));
endmodule
