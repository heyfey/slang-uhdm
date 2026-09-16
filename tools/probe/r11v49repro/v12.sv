// v11u49 arm v12 — LAW A x the THIRD trigger (patParamEvalFuncRead26):
// an UNPACKED struct package param read WHOLE by a const-function builder,
// with no member select and no p::NAME read of it.
package p;
  typedef struct { logic [7:0] a; logic [7:0] b; } ub_t;
  typedef struct { ub_t u; logic [7:0] k; } cfg_t;
  localparam ub_t UU = '{a:8'd1, b:8'd2};      // read WHOLE by the builder only
  localparam ub_t UN = '{a:8'd3, b:8'd4};      // never read at all
  function automatic cfg_t build();
    cfg_t c;
    c.u = UU;
    c.k = 8'd9;
    return c;
  endfunction
  localparam cfg_t CFG = build();
endpackage
module v12 import p::*; (output logic [31:0] o);
  assign o = CFG.k + UN.a;
endmodule
