// § tpPropDefaultLoc241
package p;
  class item; endclass
  typedef item item_t;
  class drv #(type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
  endclass
  typedef drv #(item_t, item_t) drv_t;
endpackage
module top; endmodule
