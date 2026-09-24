// r10vbuvm29 arm H (VERIFIER) — the DOWNSTREAM ROADS the new cast now reaches
// that no other arm exercises:
//   1. `defGenProcessEmit && cesyn.left is IdentifierName` — a DEF-view
//      generate-block PROCEDURAL cast whose target is a bare IMPORTED typedef
//      name, which the emitter turns into an unsupported_typespec NAMED as
//      written.  With a STREAM operand this road was unreachable before.
//   2. a cast over a stream inside a generate-FOR body (genvar context).
//   3. a cast over a stream in a class STATIC method reached from a package.
package vh29p;
  typedef enum bit [7:0] { H0 = 8'h1, H1 = 8'h2 } hacc_e;
  typedef logic [7:0] hv_t;
endpackage

module vh29 #(parameter int N = 2) (input logic clk);
  import vh29p::*;
  bit __a[];
  hacc_e ge1;
  hv_t   gv1;
  generate
    if (N > 1) begin : gif
      always_ff @(posedge clk) ge1 <= hacc_e'({ << bit { __a }});   // bare imported typedef
      always_comb gv1 = hv_t'({ >> bit { __a }});
    end
    for (genvar k = 0; k < 2; k++) begin : gfor
      hacc_e gk;
      always_comb gk = hacc_e'({ << bit { __a }});
    end
  endgenerate
endmodule
