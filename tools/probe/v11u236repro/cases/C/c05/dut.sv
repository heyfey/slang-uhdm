// § hpSelIdxPkgFoldTsOwner236 — the right side of an elaborated continuous-assignment lvalue member path: constant, net, operation, member path, unbased literal, call
package pk;
  localparam int N = 2;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module top import pk::*; (input logic [1:0] v, output logic [1:0] o);
  function automatic logic [1:0] f(logic [1:0] x);
    return ~x;
  endfunction
  r_t [N:0] ra, rb, rc, rd, re, rf;
  assign ra[N].base.q = 2'b01;
  assign rb[N].base.q = v;
  assign rc[N].base.q = v + 2'd1;
  assign rd[N].base.q = ra[N].base.q;
  assign re[N].base.q = '1;
  assign rf[N].base.q = f(v);
  assign o = ra[N].base.q ^ rb[N].base.q ^ rc[N].base.q ^ rd[N].base.q ^ re[N].base.q ^ rf[N].base.q;
endmodule
