// § patFlatTernPickedLeafSpan250
// picked members used in the constant slots: a dimension bound, a part-select bound, an indexed width, a replication count
package p;
  typedef struct packed { int unsigned w; int unsigned n; } c_t;
  localparam c_t A = '{w: 8, n: 2};
  localparam c_t B = '{w: (A.w > 4) ? A.w : 4, n: A.n};
endpackage
module top(input logic [15:0] i, output logic [7:0] o, output logic [7:0] r);
  import p::*;
  localparam c_t K = '{w: B.w, n: 1 ? B.n : 3};
  logic [K.w-1:0] t;
  assign t = i[K.w-1:0];
  assign o = t;
  assign r = {K.n{i[K.n +: 4]}};
endmodule
