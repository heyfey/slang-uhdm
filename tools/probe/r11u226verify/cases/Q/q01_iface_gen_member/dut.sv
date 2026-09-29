// § modStructMemberQualSpan214 — struct member ranges with package-qualified bounds declared in an interface and in a generate block
package cfg;
  localparam int W = 6;
  localparam int N = 3;
endpackage
interface bus_i;
  typedef struct packed {
    logic [cfg::W-1:0] d;
    logic [cfg::N:0]   t;
  } pkt_t;
  pkt_t p;
endinterface
module top(output logic [15:0] o);
  bus_i u_b();
  if (1) begin : g
    typedef struct packed {
      logic [cfg::N-1:0] a;
      logic [cfg::W:0]   b;
    } gs_t;
    gs_t s;
    assign s = '1;
  end
  assign o = 16'(g.s);
endmodule
