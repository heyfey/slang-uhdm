// § tpPropDefaultLoc241
class item; endclass
class drv #(type REQ = item, type RSP = REQ);
  REQ req;
  RSP rsp;
endclass
typedef drv #(item, item) drv_t;
module top; drv_t d; endmodule
