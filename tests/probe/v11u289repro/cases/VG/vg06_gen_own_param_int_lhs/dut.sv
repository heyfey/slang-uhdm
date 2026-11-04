// § genCaStructParamTypedLhsShares289
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] a; } impl_t;
endpackage
module top (output int o);
  localparam q2::impl_t IMPL = '{ pad: 4'h9, a: 8'b1010_0110 };
  if (1) begin : g
    assign o = IMPL.a;
  end
endmodule
