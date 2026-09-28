// law enumImportParentLastWriter180 law enumImpDefOwner180v (r11u190: a package enum imported by three modules in two files; the alphabetically last importer sits in the second file)
package p;
  typedef enum logic [1:0] {IDLE, RUN, DONE} st_e;
endpackage
module top;
  import p::*;
  st_e s0;
  amod ua();
  mmod um();
  zmod uz();
endmodule
module amod;
  import p::*;
  st_e sa;
endmodule
