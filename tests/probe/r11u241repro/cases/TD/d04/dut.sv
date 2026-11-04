// § tpPropDefaultLoc241
package p;
  class item; endclass
  class drv #(type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
  endclass
  class user;
    drv #(item, item) d;
  endclass
endpackage
module top; endmodule
