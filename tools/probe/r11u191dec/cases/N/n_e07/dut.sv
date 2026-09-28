// law enumImportParentLastWriter180 law enumImpDefOwner180v (r11u190: the winning importer is parameterized and instantiated twice in a generate loop)
package p;
  typedef enum logic [1:0] {F0, F1, F2} e_t;
endpackage
module zmod #(parameter int W = 1);
  import p::*;
  e_t x [W];
endmodule
module amod;
  import p::*;
  e_t y;
endmodule
module top;
  amod ua();
  for (genvar g = 0; g < 2; g++) begin : G
    zmod #(.W(g + 1)) uz();
  end
endmodule
