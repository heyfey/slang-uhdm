// v92 adversarial arm 3 — CONDITION faces.
// condTrue92 evaluates the condition with slang's tryEval, which is STRONGER
// than Surelog's get_value(reduceExpr(cond)).  Every cell here is a place the
// two evaluators can disagree; a cell where slang folds and Surelog does not
// is a pristine-right -> patched-wrong regression.
package vp3;
  parameter int PW = 3;
  function automatic bit fpk(input int a); return a > 1; endfunction
endpackage

module v3_cond #(
    parameter bit  EN   = 1,
    parameter int  N    = 4,
    parameter      STR  = "on",
    parameter real R    = 1.5
) (
    input  logic [7:0] k,
    input  logic       sig,
    output logic [3:0] y_func,      // user constant-function condition
    output logic [3:0] y_str,       // string-compare condition
    output logic [3:0] y_real,      // real-compare condition
    output logic [3:0] y_wide,      // 96-bit condition
    output logic [3:0] y_pkgfunc,   // package constant function
    output logic [3:0] y_sys,       // a $ function ExprEval does NOT implement
    output logic [3:0] y_xcond,     // an X-valued constant condition
    output logic [3:0] y_zcond,     // a Z-valued constant condition
    output logic [3:0] y_nonc,      // non-constant condition (MUST stay ternary)
    output logic [3:0] y_two        // two-parameter expression condition
);
  function automatic bit fl(input int a); return a > 2; endfunction
  localparam logic [95:0] WIDE = 96'h1;
  localparam logic [3:0]  XC   = 4'bx0x0;
  localparam logic [3:0]  ZC   = 4'bz0z0;

  assign y_func    = fl(N)          ? (k[5] ^ k[1]) : 4'h0;
  assign y_str     = (STR == "on")  ? (k[5] ^ k[2]) : 4'h0;
  assign y_real    = (R > 1.0)      ? (k[5] ^ k[3]) : 4'h0;
  assign y_wide    = WIDE           ? (k[5] ^ k[4]) : 4'h0;
  assign y_pkgfunc = vp3::fpk(N)    ? (k[4] ^ k[1]) : 4'h0;
  assign y_sys     = ($countones(N[3:0]) > 0) ? (k[4] ^ k[2]) : 4'h0;
  assign y_xcond   = XC             ? (k[4] ^ k[3]) : 4'h0;
  assign y_zcond   = ZC             ? (k[3] ^ k[2]) : 4'h0;
  assign y_nonc    = sig            ? (k[3] ^ k[1]) : 4'h0;
  assign y_two     = (N > vp3::PW)  ? (k[2] ^ k[1]) : 4'h0;
endmodule
