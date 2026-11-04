// § genCaStructParamTypedLhsShares289
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] a; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, a: 5 };
endpackage
module top import q2::*; (output logic [7:0] o);
  if (1) begin : g
    assign o = IMPL.a;
  end
endmodule
