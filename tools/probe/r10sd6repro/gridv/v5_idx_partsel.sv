// v5 — an INDEXED PART-SELECT (`a5[i5 +: 4]`), a `final : public ref_obj`
// spelling the switch never names.
package p5;
  logic [7:0] a5 = 8'h5;
  int i5 = 1;
  logic [3:0] b5 = a5[i5 +: 4];
endpackage
package q5;
  import p5::*;
  class c5;
    int own5;
  endclass
endpackage
module m5;
  q5::c5 h5;
endmodule
