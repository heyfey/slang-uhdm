// § retPkgQualTdNoAlias196: qualified returns of a signed bit vector, a one-bit logic and an int typedef, with explicit return and name assignment
package P;
  typedef bit signed [3:0] sb_t;
  typedef logic l1_t;
  typedef int i_t;
endpackage
module top(output wire [31:0] o1, o2, o3);
  function automatic P::sb_t f1(input int a);
    return a;
  endfunction
  function automatic P::l1_t f2(input int a);
    f2 = a[0];
  endfunction
  function automatic P::i_t f3(input int a);
    return a + 1;
  endfunction
  assign o1 = f1(3);
  assign o2 = f2(3);
  assign o3 = f3(3);
endmodule
