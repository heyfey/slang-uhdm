// § tpPropDefaultLoc241
package p;
  class item; endclass
  class drv #(type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
  endclass
  class sub extends drv #(item, item);
    int k;
  endclass
endpackage
module top; endmodule
