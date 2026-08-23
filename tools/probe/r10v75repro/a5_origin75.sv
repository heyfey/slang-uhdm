// r10v75 arm a5 -- ORIGINS read from a gen-scope always_comb: derived chains
// 2-3 hops, negative, 64-bit, implicit type, unsigned int, byte/shortint,
// a QUALIFIED read (negative control), a module parameter, a module localparam,
// a gen-scope localparam, the genvar, and a parameter from a SECOND package.
package a5p;
  parameter int  NB   = 4;
  parameter int unsigned NU = 3;
  parameter      UT   = 5;              // implicitly typed
  parameter int  NEG  = -3;
  parameter longint LL = 64'd9000000000;
  parameter byte  BY  = 8'sd7;
  parameter shortint SI = 16'sd9;
  parameter bit [7:0] TB = 8'hA5;
  localparam int H1 = NB * 2;           // 1 hop
  localparam int H2 = H1 - 1;           // 2 hops
  localparam int H3 = $clog2(H2) + H1;  // 3 hops
endpackage
package a5q;
  parameter int QB = 6;
endpackage

module a5m #(parameter int MP = 2) (input logic clk, output logic [63:0] o);
  import a5p::*;
  localparam int ML = 7;
  logic [63:0] r [0:15];
  for (genvar g = 0; g < 2; g++) begin : gen_f
    localparam int GL = 11;
    always_comb r[0]  = {NB{1'b1}};        // wildcard int
    always_comb r[1]  = {NU{1'b1}};        // int unsigned
    always_comb r[2]  = {UT{1'b1}};        // implicit
    always_comb r[3]  = NEG + 1;           // negative
    always_comb r[4]  = LL + 1;            // 64-bit
    always_comb r[5]  = BY + 1;            // byte
    always_comb r[6]  = SI + 1;            // shortint
    always_comb r[7]  = {TB{1'b0}} | 1;    // bit [7:0]
    always_comb r[8]  = H1 + 1;            // 1 hop
    always_comb r[9]  = H2 + 1;            // 2 hops
    always_comb r[10] = H3 + 1;            // 3 hops
    always_comb r[11] = a5p::NB + 1;       // QUALIFIED (negative control)
    always_comb r[12] = a5q::QB + 1;       // other package, qualified
    always_comb r[13] = MP + 1;            // module parameter
    always_comb r[14] = ML + 1;            // module localparam
    always_comb r[15] = GL + g + 1;        // gen-scope localparam + genvar
  end
  assign o = r[0]^r[1]^r[2]^r[3]^r[4]^r[5]^r[6]^r[7]^r[8]^r[9]^r[10]^r[11]^r[12]^r[13]^r[14]^r[15];
endmodule

module a5body (input logic clk, output logic [63:0] o);
  import a5p::*;
  localparam int ML = 7;
  logic [63:0] r [0:15];
  always_comb r[0]  = {NB{1'b1}};
  always_comb r[1]  = {NU{1'b1}};
  always_comb r[2]  = {UT{1'b1}};
  always_comb r[3]  = NEG + 1;
  always_comb r[4]  = LL + 1;
  always_comb r[5]  = BY + 1;
  always_comb r[6]  = SI + 1;
  always_comb r[7]  = {TB{1'b0}} | 1;
  always_comb r[8]  = H1 + 1;
  always_comb r[9]  = H2 + 1;
  always_comb r[10] = H3 + 1;
  always_comb r[11] = a5p::NB + 1;
  always_comb r[12] = a5q::QB + 1;
  always_comb r[13] = 1;
  always_comb r[14] = ML + 1;
  always_comb r[15] = 1;
  assign o = r[0]^r[1]^r[2]^r[3]^r[4]^r[5]^r[6]^r[7]^r[8]^r[9]^r[10]^r[11]^r[12]^r[13]^r[14]^r[15];
endmodule

module a5top (input logic clk, output logic [63:0] o1, o2, o3);
  a5m #(2) u_1 (.clk(clk), .o(o1));
  a5m #(5) u_2 (.clk(clk), .o(o2));
  a5body   u_b (.clk(clk), .o(o3));
endmodule
