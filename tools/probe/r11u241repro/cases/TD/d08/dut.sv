// § tpPropDefaultLoc241
module top;
  class item; endclass
  class drv #(type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
  endclass
  typedef drv #(item, item) drv_t;
  drv_t d;
endmodule
