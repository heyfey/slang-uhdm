// § tpPropDefaultLoc241
package p;
  class item; endclass
  class drv #(type REQ =
                 item,
              type RSP = REQ);
    REQ req;
    RSP rsp[$];
    REQ arr[4];
  endclass
endpackage
module top;
  p::drv #(p::item, p::item) d;
endmodule
