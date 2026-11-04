// § ifacePortTdCastLogicTs405
interface types_if;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } hdr_t;
endinterface
interface flit_if (types_if types);
  typedef types.hdr_t hdr_t;
  logic [7:0] data;
  hdr_t h;
  always_comb begin
    h = hdr_t'(data);
  end
endinterface
module top;
  types_if t();
  flit_if f(t);
endmodule
