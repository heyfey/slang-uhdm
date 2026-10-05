// § tpClsDefaultAtClassName241
class base #(int W = 1); endclass
class drv #(type REQ = base #(2), type RSP = base);
  REQ req;
  RSP rsp;
endclass
module top;
  drv d;
  drv #(base #(5)) e;
endmodule
