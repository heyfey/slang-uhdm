// § streamBraceInMacroBody246
`include "defs.svh"
package p;
  class c;
    int arr[];
    bit [63:0] bits;
    function void f();
      `PACK_INTN(arr, 32)
    endfunction
    function void g();
      `UNPACK_INTN(arr, 32)
    endfunction
  endclass
endpackage
module top;
endmodule
