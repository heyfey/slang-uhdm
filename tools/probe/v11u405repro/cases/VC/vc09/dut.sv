// § ifacePortTdCastLogicTs405
interface types_if #(parameter int W = 4);
  typedef struct packed { logic [W-1:0] a; logic [W-1:0] b; } hdr_fields;
  typedef hdr_fields hdr_t;
endinterface
interface flit_if #(parameter int N = 2) (types_if types);
  typedef types.hdr_t hdr_t;
  logic [7:0] data;
  for (genvar i = 0; i < N; ++i) begin : g_debug
    hdr_t h;
    always_comb h = hdr_t'(data);
  end
endinterface
module rx (types_if types);
  flit_if f[2](types);
endmodule
module top;
  types_if #(4) t();
  rx r(t);
endmodule
