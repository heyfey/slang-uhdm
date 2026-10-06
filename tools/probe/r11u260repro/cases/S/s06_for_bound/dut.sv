// § shadowedImportTsRefOwner260 (a for-loop bound)
package rp;
  localparam int N = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int N = 2;
  always_comb begin
    q = '0;
    for (int i = 0; i < N; i++) q[i] = a[i];
  end
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
