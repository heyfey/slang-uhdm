// § hpSelIdxPkgFoldTsOwner236 — Earlgrey #106660: a plain bit select (no member) with a package parameter index
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module top import pk::*; (input logic [3:0] v, output logic o, output logic [3:0] w);
  assign w[N] = 1'b1;
  assign w[0] = 1'b0;
  assign w[3:1+N] = '0;
  assign o = v[N];
endmodule
