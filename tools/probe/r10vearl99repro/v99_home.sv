// r10v99 ADVERSARIAL -- the HOMES: module, submodule (x3 instances of ONE
// span), generate scope, package function, class method, interface.
package ph99;
  typedef struct packed { logic [2:0] a3; logic [4:0] b5; } h_t;
  function automatic logic [7:0] pf(input logic s);
    h_t v;
    v = s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 };
    return v;
  endfunction
  class C99;
    function automatic logic [7:0] cm(input logic s);
      h_t v;
      v = s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 };
      return v;
    endfunction
  endclass
endpackage
interface if99 (input logic s);
  ph99::h_t w;
  assign w = s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 };
endinterface
module hsub99 (input logic s, output ph99::h_t o);
  assign o = s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 };
endmodule
module v99_home (input logic s,
                 output ph99::h_t o_mod,
                 output ph99::h_t o_i0, output ph99::h_t o_i1, output ph99::h_t o_i2,
                 output ph99::h_t o_gen,
                 output logic [7:0] o_pkgf);
  assign o_mod = s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 };
  hsub99 u0 (.s(s), .o(o_i0));
  hsub99 u1 (.s(s), .o(o_i1));
  hsub99 u2 (.s(s), .o(o_i2));
  generate
    if (1) begin : g_blk
      ph99::h_t gw;
      assign gw = s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 };
    end
  endgenerate
  assign o_gen = g_blk.gw;
  assign o_pkgf = ph99::pf(s);
  if99 u_if (.s(s));
endmodule
