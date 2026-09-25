// § pkgPatListingCopyWhenShared163
package pk;
  typedef struct packed { logic a; logic b; } t_t;
  parameter t_t D = '{a: 1'b0, b: 1'b1};
endpackage
module m (input pk::t_t a, output logic o); assign o = ^a; endmodule
module top(output logic o); m u(.a(pk::D), .o(o)); endmodule
