// § classTpChainRootShares180
package pkg;
  class base_c; endclass
  class holder #(type REQ=base_c, type RSP=REQ);
    REQ m;
    RSP n;
    function void f(REQ x);
      m = x;
    endfunction
    function void g(RSP y);
      n = y;
    endfunction
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
