// § classTpChainRootShares180
package pkg;
  class base_c; endclass
  class holder #(type REQ=base_c, type RSP=REQ);
    REQ m;
    RSP n;
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
