// § retPkgQualTdNoAlias196: a qualified return of a typedef that aliases another package's typedef, and of a packed array of a qualified typedef
package Q;
  typedef logic [5:0] u_t;
endpackage
package P;
  typedef Q::u_t t_t;
  typedef logic [1:0] two_t;
endpackage
module top(output wire [31:0] o1, o2);
  function automatic P::t_t f1(input int a);
    return a;
  endfunction
  function automatic P::two_t [2:0] f2(input int a);
    return a;
  endfunction
  assign o1 = f1(5);
  assign o2 = f2(5);
endmodule
