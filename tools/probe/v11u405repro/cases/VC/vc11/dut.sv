// § ifacePortTdCastLogicTs405
interface types_if #(parameter int W = 4);
  typedef logic [W-1:0] hdr_t;
endinterface
interface flit_if (types_if types);
  typedef types.hdr_t hdr_t;
  logic [7:0] data;
  logic [7:0] y;
  assign y = hdr_t'(data) + 8'd1;
endinterface
module top (output logic [7:0] o);
  types_if #(6) t();
  flit_if f(t);
  assign o = f.y;
endmodule
