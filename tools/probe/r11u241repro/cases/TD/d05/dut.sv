// § tpPropDefaultLoc241
package p;
  class item; endclass
  class drv #(type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
  endclass
endpackage
module top;
  typedef p::drv #(p::item, p::item) drv_t;
  drv_t d;
endmodule
