// § pkgVarLvalueScopeSep292
package p;
  int q;
  logic [7:0] w;
endpackage
package r;
  class c;
    function void h();
      p::q += 1;
      p::q++;
      --p::q;
      p::w[3] = 1'b1;
      p::w[2:1] = 2'b01;
    endfunction
  endclass
  function automatic void f();
    p::q <<= 2;
    {p::q} = 5;
  endfunction
endpackage
module top; initial r::f(); endmodule
