// § pkgPatListingCopyWhenShared163
package pk;
  typedef struct packed { logic a; logic b; } t_t;
  parameter t_t D = '{a: 1'b0, b: 1'b1};
endpackage
module m (input pk::t_t [1:0] a, output logic o); assign o = ^a; endmodule
module top(output logic o1, o2); m u1(.a({2{pk::D}}), .o(o1)); m u2(.a({pk::D, pk::D}), .o(o2)); endmodule
