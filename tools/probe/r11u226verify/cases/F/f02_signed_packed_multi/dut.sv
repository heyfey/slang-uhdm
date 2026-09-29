// § tfArgScalarTdWriter223 — signed and unsigned keywords and packed multi-dimensional bit and logic typedefs as package-function formals
package p;
  typedef int unsigned        t_iu;
  typedef byte unsigned       t_bu;
  typedef shortint unsigned   t_su;
  typedef bit signed [7:0]    t_bs8;
  typedef logic signed [3:0]  t_ls4;
  typedef bit [1:0][3:0]      t_b2d;
  typedef logic [2:0][1:0]    t_l2d;
  function automatic int f(t_iu a, t_bu b, t_su c, t_bs8 d, t_ls4 e, t_b2d g, t_l2d h);
    return int'(a) + int'(b) + int'(c) + int'(d) + int'(e) + int'(g) + int'(h);
  endfunction
endpackage
module top(output int o);
  assign o = p::f(1, 2, 3, 4, 5, 6, 7);
endmodule
