// § ifacePortTdCastLogicTs405
interface types_if #(parameter int W = 4);
  typedef struct packed { logic [W-1:0] a; logic [W-1:0] b; } hdr_fields;
  typedef hdr_fields hdr_t;
endinterface
module m (types_if types, input logic [7:0] data, output logic [7:0] o);
  typedef types.hdr_t hdr_t;
  hdr_t h;
  always_comb h = hdr_t'(data);
  assign o = h;
endmodule
module top (input logic [7:0] d, output logic [7:0] o);
  types_if #(4) t();
  m u(t, d, o);
endmodule
