// § tfArgScalarTdWriter223 — two packages with the same scalar typedef name of different kinds, each with a class method formal, and a module function of each
package p1;
  typedef int     H_T;
  class c1; function void f(H_T h); endfunction endclass
  function automatic int g1(H_T h); return h; endfunction
endpackage
package p2;
  typedef byte    H_T;
  class c2; function void f(H_T h); endfunction endclass
  function automatic int g2(H_T h); return h; endfunction
endpackage
module top(output int o);
  assign o = p1::g1(1) + p2::g2(2);
endmodule
