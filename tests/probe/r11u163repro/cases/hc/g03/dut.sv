// § pkgPatListingCopyWhenShared163
package pk;
  typedef struct packed { logic a; logic b; } t_t;
  parameter t_t D = '{a: 1'b0, b: 1'b1};
endpackage
module top(output pk::t_t o); assign o = pk::D; endmodule
