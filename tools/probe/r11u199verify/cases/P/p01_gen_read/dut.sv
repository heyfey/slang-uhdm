// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct { int unsigned N; int unsigned W; } cfg_t;
  localparam cfg_t CFG = '{N:2, W:4};
  typedef logic [CFG.W-1:0] word_t;
endpackage
module top import p::*; (input word_t i [2], output word_t o [2]);
  for (genvar k = 0; k < CFG.N; k++) begin : g
    word_t r;
    assign r = i[k];
    assign o[k] = r;
  end
endmodule
