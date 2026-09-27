// § classTpChainRootShares180 (verifier: a three-member chain with a formal on the middle member)
package pkg;
  class base_c; endclass
  class holder #(type A=base_c, type B=A, type C=B);
    C m;
    function void f(B x); endfunction
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
