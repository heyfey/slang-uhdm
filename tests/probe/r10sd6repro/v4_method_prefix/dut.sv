// v4 — a METHOD CALL whose PREFIX is a reference: `int b4 = o4.get4();`
package p4;
  class k4;
    function int get4(); return 3; endfunction
  endclass
  k4 o4 = new();
  int b4 = o4.get4();
endpackage
package q4;
  import p4::*;
  class c4;
    int own4;
  endclass
endpackage
module m4;
  q4::c4 h4;
endmodule
