// § pkgPatListingCopyWhenShared163
package pk;
  typedef struct packed { logic p; logic n; } tx_t;
  parameter tx_t D = '{p: 1'b1, n: 1'b0};
endpackage
module sub #(parameter int N = 2) (input logic [2*N-1:0] a, output logic [2*N-1:0] o); assign o = a; endmodule
module top (output logic [5:0] o [2]);
  for (genvar g = 0; g < 2; g++) begin : G
    sub #(.N(3)) u(.a({3{pk::D}}), .o(o[g]));
  end
endmodule
