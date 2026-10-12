// § pkgVarLvalueScopeSep292
package p; logic [7:0] q; int n; endpackage
package r;
  function automatic void o(output int z); z = 1; endfunction
  function automatic void f(logic [7:0] v);
    {>>{p::q}} = v;
    o(p::n);
    p::n = p::n + 1;
  endfunction
endpackage
module top; endmodule
