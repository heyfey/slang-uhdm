// § ifaceWildcardTdNameOrder180 (verifier: package with an enum and structs; the interface is also a port of a module)
package p;
  typedef enum logic [1:0] {IDLE, BUSY} st_e;
  typedef struct packed { logic [3:0] d; st_e s; } rsp_t;
  typedef struct packed { logic [3:0] a; } req_t;
endpackage
interface mem_if(input logic clk);
  import p::*;
  req_t q; rsp_t r;
endinterface
module top(input logic clk, output logic [3:0] o);
  mem_if b(.clk(clk));
  assign o = b.q.a;
endmodule
