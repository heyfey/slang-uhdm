// § genCaStructParamTypedLhsShares289
package q2;
  typedef struct packed { logic [3:0] pad; logic [7:0] a; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, a: {4'h1, 4'h2}, cfg: 2'b11 };
endpackage
module top import q2::*; #(parameter int K = 1) (output logic [7:0] o);
  case (K)
    1: begin : g
      assign o = IMPL.a;
    end
    default: begin : h
      assign o = 8'h0;
    end
  endcase
endmodule
