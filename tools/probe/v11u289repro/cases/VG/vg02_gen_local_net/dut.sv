// § genCaStructParamTypedLhsShares289
package pk;
  typedef struct packed { logic [3:0] n; logic [7:0] m; logic [11:0] w; } s_t;
  localparam s_t K = '{n: 4'h6, m: 8'b1100_0011, w: 12'h5A3};
endpackage
module top import pk::*; (output logic [5:0] o);
  if (1) begin : g
    logic [5:0] t;
    assign t = K.w;
    assign o = t;
  end
endmodule
