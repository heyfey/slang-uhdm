// § tpPropDefaultLoc241
package p;
  class item; endclass
  class drv #(int N = 1, type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
    int w = N;
  endclass
  typedef drv #(1, item, item) drv_t;
endpackage
module top; endmodule
