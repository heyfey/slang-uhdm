// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  function automatic int f(int a);
    logic [p::W-1:0] v;
    v = a;
    return int'(v);
  endfunction
endpackage
module top(output int o);
  assign o = q::f(3);
endmodule
