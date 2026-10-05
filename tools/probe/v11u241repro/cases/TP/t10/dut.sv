// § tpPropDefaultLoc241
package p;
  interface class ic; endclass
  class item implements ic; endclass
  class drv #(type REQ = ic, type RSP = item);
    REQ req;
    RSP rsp;
  endclass
  typedef drv #(ic, item) drv_t;
endpackage
module top; endmodule
