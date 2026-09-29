// § tfArgScalarTdWriter223 — control: a typedef with an unpacked dimension and a typedef of a typedef'd vector, beside a plain scalar typedef formal
package p;
  typedef int         A4_T [4];
  typedef bit [7:0]   B_T;
  typedef int         I_T;
  function automatic int f(A4_T a, B_T b, I_T c);
    return a[0] + b + c;
  endfunction
endpackage
module top(output int o);
  assign o = p::f('{1, 2, 3, 4}, 8'd5, 6);
endmodule
