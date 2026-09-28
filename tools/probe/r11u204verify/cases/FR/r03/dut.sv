// § retPkgQualTdNoAlias196: class-scoped returns C::T and a parameterized class's C#(6)::T beside a package-qualified one
package P;
  typedef logic [3:0] n_t;
endpackage
class C #(int W = 4);
  typedef logic [W-1:0] T;
endclass
class D;
  typedef logic [2:0] T;
endclass
module top(output wire [31:0] o1, o2, o3);
  function automatic D::T f1(input int a); return a; endfunction
  function automatic C#(6)::T f2(input int a); return a; endfunction
  function automatic P::n_t f3(input int a); return a; endfunction
  assign o1 = f1(2);
  assign o2 = f2(2);
  assign o3 = f3(2);
endmodule
