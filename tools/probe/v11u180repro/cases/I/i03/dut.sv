// § ifaceWildcardTdNameOrder180 (verifier: wildcard import beside the interface's own typedef)
package p;
  typedef struct packed { logic [3:0] d; } rsp_t;
  typedef struct packed { logic [3:0] a; } req_t;
endpackage
interface mem_if;
  import p::*;
  typedef logic [1:0] m_t;
  req_t q; rsp_t r; m_t m;
  modport mp(input q, output r, input m);
endinterface
module user(mem_if.mp i);
  assign i.r = i.q;
endmodule
module top;
  mem_if b();
  user u(.i(b));
endmodule
