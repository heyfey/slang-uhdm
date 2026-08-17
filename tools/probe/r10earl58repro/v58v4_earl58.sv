// v58 VERIFIER arm V4 — the NON-gen-scope parameter kinds that must be
// UNTOUCHED (module param, package param, a parent MODULE's param seen from a
// nested gen scope), plus INTERFACE and PROGRAM gen scopes, plus a d1 param
// whose declared type is a typedef/enum, plus an ARRAY of gen blocks reached
// through an interface.
package v4_pkg;
  parameter int unsigned PW = 12;
endpackage

interface v4_if (input logic clk, input logic [63:0] v);
  if (1) begin : gi
    localparam int unsigned IW = 14;
    if (1) begin : gii
      logic [63:0] r;
      always_ff @(posedge clk) r <= v[IW-2:0];
    end
  end
endinterface

module v4_earl58 #(parameter int unsigned MP = 16)
  (input logic clk, input logic [63:0] v, output logic [63:0] o);
  v4_if   u_if(.clk(clk), .v(v));
  localparam int unsigned ML = 18;
  if (1) begin : g1
    if (1) begin : g2
      logic [63:0] rm, rp, rl;
      always_ff @(posedge clk) rm <= v[MP-2:0];             // MODULE param
      always_ff @(posedge clk) rp <= v[v4_pkg::PW-2:0];     // PACKAGE param
      always_ff @(posedge clk) rl <= v[ML-2:0];             // module localparam
    end
  end
  // typed/untyped/enum-typed d1 parameters
  if (1) begin : t_a
    typedef enum int unsigned { E0 = 3, E1 = 21 } e_t;
    localparam e_t          TE = E1;
    localparam              TU = 22;
    localparam int          TS = 23;
    localparam bit [7:0]    TB = 8'd24;
    if (1) begin : t_b
      logic [63:0] re, ru, rs, rb;
      always_ff @(posedge clk) re <= v[TE-2:0];
      always_ff @(posedge clk) ru <= v[TU-2:0];
      always_ff @(posedge clk) rs <= v[TS-2:0];
      always_ff @(posedge clk) rb <= v[TB-2:0];
    end
  end
  assign o = v;
endmodule
