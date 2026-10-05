// § streamBraceInMacroBody246
`define SL(V,N) \
   begin \
     bits = { << byte { V with [0 +: N] }}; \
     { >> { V with [0 +: N] }} = bits; \
   end
`define OUTER(V) `SL(V, 2)
package p;
  class c;
    byte arr[];
    bit [63:0] bits;
    function void f();
      `SL(arr, 4)
      `OUTER(arr)
    endfunction
  endclass
endpackage
module top;
endmodule
