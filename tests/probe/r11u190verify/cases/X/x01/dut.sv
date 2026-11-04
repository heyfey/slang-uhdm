// § enumImportParentLastWriter180 § rootPathElemOwnName181 § rootPathFullNameByChain181 (r11u190 cross: a package enum read through $root paths into two importers)
package p;
  typedef enum logic [1:0] {IDLE, RUN} st_e;
endpackage
module zmod;
  import p::*;
  st_e st;
endmodule
module amod;
  import p::*;
  st_e sa;
endmodule
module top;
  import p::*;
  zmod uz();
  amod ua();
  logic hit;
  always_comb hit = ($root.top.uz.st == RUN);
  initial if ($root.top.ua.sa == IDLE) hit = 1;
endmodule
