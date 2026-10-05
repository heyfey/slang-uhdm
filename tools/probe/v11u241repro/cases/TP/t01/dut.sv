// § tpPropDefaultLoc241
package o;
  class item; endclass
endpackage
package p;
  class drv #(type REQ = o::item, type RSP = REQ);
    REQ req;
    RSP rsp;
  endclass
  typedef drv #(o::item, o::item) drv_t;
endpackage
module top; endmodule
