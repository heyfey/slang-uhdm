// § tpPropDefaultLoc241
package p;
  class item; endclass
  class drv #(type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
  endclass
  typedef drv #(item, item) drv_t;
endpackage
module top; endmodule
