// § streamBraceInMacroBody246
`define UNP(V) { << int { V }} = bits;
`define UNP2(V) { >> 8 { V }} = bits[15:0];
package p;
  class c;
    int arr[];
    byte b2[];
    bit [63:0] bits;
    function void f();
      `UNP(arr)
      `UNP2(b2)
    endfunction
  endclass
endpackage
module top;
endmodule
