// § hpSelIdxPkgFoldTsOwner236 — package-parameter index in member paths: procedural lvalues, rvalues, inc/dec
package pk;
  localparam int N = 2;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module top import pk::*; (input logic clk, output logic [1:0] o, output logic [1:0] o2);
  r_t [N:0] rc;
  r_t [N:0] rp;
  assign rc[N-1:0] = '0;
  assign rc[N].base.q = 2'b01;
  assign rc[N].size.q = rc[N].base.q;
  always_ff @(posedge clk) begin
    rp[N].base.q <= rc[N].size.q;
    rp[N].size.q++;
  end
  assign o = rp[N].base.q;
  assign o2 = rp[N].size.q;
endmodule
