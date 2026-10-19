// § ifacePortTdCastLogicTs405
interface types_if;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } hdr_t;
endinterface
interface flit_if (types_if types);
  typedef types.hdr_t hdr_t;
  logic [7:0] data;
  hdr_t h;
  always_comb h = hdr_t'(data);
endinterface
module rx (types_if types);
  flit_if f[2](types);
endmodule
module top;
  types_if t();
  rx r(t);
endmodule
