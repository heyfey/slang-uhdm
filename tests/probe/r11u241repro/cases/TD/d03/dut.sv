// § tpPropDefaultLoc241
package p;
  class item; endclass
  class other; endclass
  class drv #(type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
  endclass
  typedef drv #(other, other) drv_t;
endpackage
module top; endmodule
