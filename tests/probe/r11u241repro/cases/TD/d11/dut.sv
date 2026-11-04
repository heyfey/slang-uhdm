// § tpPropDefaultLoc241
package p;
  class item; endclass
  class sub extends item; endclass
  class drv #(type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
  endclass
  typedef drv #(item, item) drv_t;
  typedef drv #(sub, sub) drv2_t;
  typedef drv #(item) drv3_t;
endpackage
module top; endmodule
