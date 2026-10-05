// § streamBraceInMacroBody246
package p;
  class c;
    function void f(bit [63:0] v);
      int arr[];
      int q[];
      { << int { arr }} = {{32{1'b0}}, v};
      q = { << int { arr }};
      { >> { arr }} = v;
      { << 8 { arr }} = v;
    endfunction
  endclass
endpackage
module top;
  int a[];
  bit [63:0] v;
  initial { << int { a }} = v;
endmodule
