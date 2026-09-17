// g3 — HOLDER KINDS x COPY COUNTS.  One package-selected UNPACKED struct
// localparam, materialized into an interface, two module instances, a module
// WITH a parameter port list, a module whose port list SELECTS it (the landed
// § modDefImportPatSel road) and a RE-EXPORTING package.
package p3;
  typedef struct { int unsigned a; int unsigned b; } u3_t;
  localparam u3_t B3 = '{a: 4, b: 8};
  typedef logic [B3.a-1:0] v3_t;
endpackage

interface g3if import p3::*; (input logic clk);
  v3_t d;
endinterface

module g3child import p3::*; (input logic clk);
  v3_t d;
  assign d = '0;
endmodule

module g3port import p3::*; #(parameter int W = 4) (input logic clk);
  v3_t d;
  logic [W-1:0] u;
  assign d = '0;
  assign u = '0;
endmodule

module g3sel import p3::*; #(parameter int W = 4, localparam int X = B3.b) (input logic clk);
  logic [X-1:0] d;
  logic [W-1:0] u;
  assign d = '0;
  assign u = '0;
endmodule

package p3b;
  import p3::*;
  export p3::*;
  localparam int Q3 = 1;
endpackage

module g3top(input logic clk);
  g3if    u_if (.clk(clk));
  g3child u_c1 (.clk(clk));
  g3child u_c2 (.clk(clk));
  g3port  u_p  (.clk(clk));
  g3sel   u_s  (.clk(clk));
endmodule
