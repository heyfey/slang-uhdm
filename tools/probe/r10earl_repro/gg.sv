// r10earl4 gg.sv — § impCopyBasedDecKeep.
// 12 Earlgrey AllModules heads, all at ibex_pkg.sv:476:38
// (`parameter logic [1:0] CSR_MISA_MXL = 2'd1;`) reached through a MODULE's
// MATERIALIZED IMPORT COPY (`import ibex_pkg::*;`): golden's copy keeps
// `2'd1` DEC / size 2, we rewrite to INT `1`.  Rows walk the based bases and
// the declared widths so the fold direction is measured, not guessed; the
// q.sv (pass 2) body-read case folds the OTHER way, so the two must agree.
package gp;
  parameter logic [1:0] GDEC   = 2'd1;   // the ibex shape
  parameter logic [3:0] GDEC4  = 4'd3;
  parameter logic [3:0] GHEX   = 4'h2;
  parameter logic [3:0] GBIN   = 4'b1010;
  parameter logic [3:0] GOCT   = 4'o7;
  parameter int unsigned GINT  = 11;     // plain decimal control
  parameter logic [7:0] GWIDE  = 8'd200;
endpackage

module gchild (
  input  logic [3:0] i,
  output logic [3:0] o
);
  import gp::*;
  // read one of them so the import is live
  assign o = i ^ {2'b0, GDEC} ^ GDEC4 ^ GHEX ^ GBIN ^ GOCT ^ GWIDE[3:0] ^
             GINT[3:0];
endmodule

module gg (input logic [3:0] i, output logic [3:0] o);
  gchild u_c (.i(i), .o(o));
endmodule
