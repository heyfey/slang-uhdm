// r10v75 arm a7 -- WHERE the wildcard import sits: module header, module body,
// the GENERATE BLOCK itself, and a package with no import at all (qualified
// only).  importedParamDefTs is populated per import site, so each is a
// distinct emitter path for the same law.
package a7p;
  parameter int NB = 4;
endpackage

module a7hdr import a7p::*; (input logic clk, output logic [31:0] o);
  logic [31:0] r;
  if (1) begin : gen_h
    always_comb r = {NB{1'b1}};      // A7_H header import
  end
  assign o = r;
endmodule

module a7body (input logic clk, output logic [31:0] o);
  import a7p::*;
  logic [31:0] r;
  if (1) begin : gen_b
    always_comb r = {NB{1'b1}};      // A7_B body import
  end
  assign o = r;
endmodule

module a7blk (input logic clk, output logic [31:0] o);
  logic [31:0] r;
  if (1) begin : gen_i
    import a7p::*;                   // import INSIDE the generate block
    always_comb r = {NB{1'b1}};      // A7_I block import
  end
  assign o = r;
endmodule

module a7qual (input logic clk, output logic [31:0] o);
  logic [31:0] r;
  if (1) begin : gen_q
    always_comb r = {a7p::NB{1'b1}}; // A7_Q no import, QUALIFIED only
  end
  assign o = r;
endmodule

module a7off (input logic clk, output logic [31:0] o);
  import a7p::*;
  logic [31:0] r;
  if (0) begin : gen_off
    always_comb r = {NB{1'b1}};      // A7_OFF uninstantiated branch
  end else begin : gen_on
    always_comb r = {NB{1'b1}} ^ 1;  // A7_ON taken else arm
  end
  assign o = r;
endmodule

module a7top (input logic clk, output logic [31:0] o);
  logic [31:0] a,b,c,d,e;
  a7hdr  u1 (.clk(clk), .o(a));
  a7body u2 (.clk(clk), .o(b));
  a7blk  u3 (.clk(clk), .o(c));
  a7qual u4 (.clk(clk), .o(d));
  a7off  u5 (.clk(clk), .o(e));
  assign o = a^b^c^d^e;
endmodule
