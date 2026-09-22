// r11v91 BREAK arm v2 — THE ROADS THE DECODE DOES NOT NAME.  LAW A keys on
// "the symbol is homed in a Package or the CompilationUnit", but the decoded
// producer road is `paPackage_scope` — the `pkg::name` SYNTAX.  An IMPORTED
// bare name and a `$unit` name are different Surelog roads with the same
// slang-side home.  Typedefs, enums and parameter (not localparam) package
// declarations are further untested shapes of `red91PkgDeclKind91` == 1.
package v2p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  typedef logic signed [7:0] sb_t;
  typedef logic [11:0]       ub_t;
  typedef enum logic [3:0] { EA = 4'd1, EB = 4'd2 } e_t;
  localparam int       WI  = 16'd5;
  localparam sb_t      WTS = 8'd3;     // a TYPEDEF'd signed declaration
  localparam ub_t      WTU = 16'd6;    // a TYPEDEF'd unsigned declaration
  localparam e_t       WE  = EB;       // an ENUM declaration
  parameter  int       WP  = 16'd8;    // a package PARAMETER, not localparam
  localparam int       WC1 = 16'd12;
  localparam logic [7:0] WC2 = WC1;    // a two-hop package chain
endpackage
package v2q;
  localparam int QI = 16'd5;
endpackage
import v2q::*;
localparam int UNITP = 16'd13;         // a COMPILATION-UNIT parameter
module v2_pkgroad91;
  import v2p::*;
  localparam logic [7:0] W1 = WI;       // IMPORTED bare name, not pkg::
  localparam logic [7:0] W2 = v2p::WTS; // typedef'd signed pkg inner
  localparam logic [7:0] W3 = v2p::WTU; // typedef'd unsigned pkg inner
  localparam logic [7:0] W4 = v2p::WE;  // enum pkg inner
  localparam logic [7:0] W5 = v2p::WP;  // package PARAMETER inner
  localparam logic [7:0] W6 = UNITP;    // compilation-unit inner
  localparam logic [7:0] W7 = v2p::WC2; // a package-internal chain
  localparam v2p::t A = '{bail: 8'hxA, a: W1, b: W2, c: W3, d: W4,
                          e: W5, f: W6, g: W7};
  v2_sink #(.R(A)) s1();
endmodule
module v2_sink #(parameter v2p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
