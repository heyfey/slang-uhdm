// § genCaStructParamTypedLhsShares289
package pk;
  typedef struct packed { logic [3:0] n; logic [7:0] m; logic [11:0] w; } s_t;
  localparam s_t K = '{n: 4'h6, m: 8'b1100_0011, w: 12'h5A3};
endpackage
module top import pk::*; (output logic [5:0] o [2], output logic [3:0] p);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = K.w;
  end
  if (1) begin : h
    assign p = K.m;
  end
endmodule
