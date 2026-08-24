// r10v78 arm v3 - the REFUSAL ladder: shapes where slang's tryEval CAN fold
// but Surelog's reduceExpr may not.  Every cell here is a candidate
// AWAY-GOLDEN (pristine keeps the operation and matches golden; the patch
// folds and does not).  Lhs is always a MODULE-BODY signal (the head pairing).
package pk3;
  typedef enum logic [3:0] { EA = 4'h5, EB = 4'hA } e3_t;
  localparam logic [3:0] PV = 4'hC;
endpackage
module v3sub #(parameter int SW = 3) ();
  localparam int LW = SW + 1;
endmodule
module v3;
  import pk3::*;
  localparam int N = 3;
  function automatic int f3(input int a);
    return a + 1;
  endfunction
  localparam int FW = f3(2);           // a const-function-derived count
  logic [15:0] r_fn, r_fc, r_enum, r_pkgv, r_bits, r_hier, r_cast2, r_sh, r_pw;
  logic [15:0] r_tern, r_neg, r_sum, r_arrp, r_strq;
  localparam logic [3:0] LARR [0:1] = '{4'h3, 4'h9};
  v3sub #(.SW(5)) u_s ();
  if (N > 0) begin : g4
    assign r_fn   = {f3(2){1'b1}};        // R1  COUNT from a const function
    assign r_fc   = {f3(1){1'b1}};        // R2  COUNT from a const function (nested)
    assign r_enum = {N{EA}};              // R3  ELEMENT a package enum member
    assign r_pkgv = {N{pk3::PV}};         // R4  ELEMENT a package localparam
    assign r_bits = {$bits(e3_t){1'b1}};  // R5  COUNT from $bits
    assign r_hier = {N{1'b1}};          // R6  (hier count is illegal in SV)
    assign r_cast2= {N{e3_t'(4'h5)}};     // R7  ELEMENT an enum CAST
    assign r_sh   = {(N<<1){1'b1}};       // R8  COUNT a shift expression
    assign r_pw   = {(2**N){1'b1}};       // R9  COUNT a power expression
    assign r_tern = {(N>1?2:5){1'b1}};    // R10 COUNT a ternary
    assign r_sum  = {(N+FW){1'b1}};       // R11 COUNT mixing two localparams
    assign r_arrp = {N{LARR[1]}};         // R12 ELEMENT an unpacked-array param
    assign r_neg  = {N{-1'b1}};           // R13 ELEMENT a unary minus
  end
endmodule
