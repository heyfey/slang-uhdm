// r10v63 — V4: VALUE domain.  negatives, >32-bit, >64-bit, X/Z, real, string,
// enum and typedef'd returns, plus arguments of every legality the fence F4
// mentions (integral vs unpacked-array vs string vs real).
// MEASUREMENT ONLY.
typedef enum logic [3:0] { EA = 3, EB = 9 } en4_t;
typedef logic [79:0] w80_t;

function automatic integer f_neg   (integer v); return -v;                endfunction
function automatic integer f_negsub(integer v); return 1 - v;             endfunction
function automatic longint f_big   (longint v); return v * 65536;         endfunction
function automatic longint f_bigsub(longint v); return v - 1;             endfunction
function automatic w80_t   f_w80   (int v);     return {40'hdeadbeefaa, 40'h55}; endfunction
function automatic integer f_xz    (integer v); return 4'b10xz;           endfunction
function automatic real    f_real  (int v);     return 2.5;               endfunction
function automatic en4_t   f_enum  (int v);     return EB;                endfunction
function automatic integer f_argr  (real v);    return 3;                 endfunction
function automatic integer f_args  (string v);  return 4;                 endfunction
function automatic integer f_cast  (int v);     return integer'(v - 1);   endfunction
function automatic integer f_signl (integer v); return $signed(v) - 1;    endfunction

module s_val #(parameter int V = 300, parameter longint LV = 64'h1_0000_0000) (output logic o);
  localparam int          n_neg    = f_neg(V);
  localparam int          n_negsub = f_negsub(V);
  localparam byte         n_negb   = f_neg(V);
  localparam bit [7:0]    n_negb8  = f_neg(V);
  localparam bit signed [7:0] n_negb8s = f_neg(V);
  localparam longint      n_big    = f_big(LV);
  localparam longint      n_bigsub = f_bigsub(LV);
  localparam int          n_bigtr  = f_big(LV);
  localparam logic [63:0] n_big64  = f_big(LV);
  localparam logic [79:0] n_w80    = f_w80(V);
  localparam int          n_w80tr  = f_w80(V);
  localparam int          n_xz     = f_xz(V);
  localparam logic [7:0]  n_xz8    = f_xz(V);
  localparam int          n_realv  = int'(f_real(V));
  localparam int          n_enum   = int'(f_enum(V));
  localparam en4_t        n_enumt  = f_enum(V);
  localparam int          n_argr   = f_argr(2.5);
  localparam int          n_args   = f_args("ab");
  localparam int          n_cast   = f_cast(V);
  localparam int          n_signl  = f_signl(V);
  assign o = |{n_neg[0],n_negsub[0],n_negb[0],n_negb8[0],n_negb8s[0],n_big[0],
               n_bigsub[0],n_bigtr[0],n_big64[0],n_w80[0],n_w80tr[0],n_xz8[0],
               n_realv[0],n_enum[0],n_enumt[0],n_argr[0],n_args[0],n_cast[0],
               n_signl[0],n_xz[0]};
endmodule

module top(output logic o1, output logic o2);
  s_val #(.V(300))                        u1 (.o(o1));
  s_val #(.V(1), .LV(64'h3_0000_0000))    u2 (.o(o2));
endmodule
