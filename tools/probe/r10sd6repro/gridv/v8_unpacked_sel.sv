// v8 — an UNPACKED-array element select with a reference index (var_select).
package p8;
  int arr8 [4];
  int i8 = 1;
  int b8 = arr8[i8];
endpackage
package q8;
  import p8::*;
  class c8;
    int own8;
  endclass
endpackage
module m8;
  q8::c8 h8;
endmodule
