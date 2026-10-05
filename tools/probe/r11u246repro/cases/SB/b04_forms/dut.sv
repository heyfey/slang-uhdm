// § streamBraceInMacroBody246
`define S1(A) { >> { A }}
`define S2(A,B) { << 8 { A, B }}
`define S3(V) begin int q[$]; q = { << int { V }}; { << int { q }} = V; end
package p;
  class c;
    bit [63:0] v;
    int a, b;
    function void f();
      int x[];
      v = `S1(a);
      v = `S2(a, b);
      `S3(v)
    endfunction
  endclass
endpackage
module top;
  int a, b;
  bit [63:0] v;
  initial v = `S2(a, b);
endmodule
