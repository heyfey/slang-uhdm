// § tpPropDefaultLoc241
package p;
  class item; endclass
  class drv #(type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
  endclass
  class sub #(type R = item) extends drv #(R, R);
    R x;
  endclass
  typedef sub #(item) sub_t;
  typedef drv #(item) d1_t;
endpackage
module top; endmodule
