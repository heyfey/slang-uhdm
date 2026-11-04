// § classTpChainRootShares180
package pkg;
  class base_c; endclass
  class other_c; endclass
  class holder #(type REQ=base_c, type RSP=REQ);
    REQ m;
    RSP n;
    function void g(RSP y);
      n = y;
    endfunction
  endclass
endpackage
module top();
pkg::holder #(pkg::base_c, pkg::other_c) c1;
endmodule
