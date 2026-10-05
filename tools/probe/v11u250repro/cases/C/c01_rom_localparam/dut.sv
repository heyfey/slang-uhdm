// § pkgArrTdBindCopies250
// a synthesizable ROM: a package array typedef as a localparam with a pattern, a variable written in always_ff and read by index
package p;
  typedef logic [7:0] mem_t [4];
endpackage
module top(input logic clk, input logic [1:0] a, input logic [7:0] d, output logic [7:0] q, output logic [7:0] r);
  import p::*;
  localparam mem_t ROM = '{8'h11, 8'h22, 8'h33, 8'h44};
  mem_t m;
  always_ff @(posedge clk) m[a] <= d;
  assign q = m[a];
  assign r = ROM[a];
endmodule
