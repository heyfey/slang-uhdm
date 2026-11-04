// § tpClsDefaultAtClassName241
package p;
  class base #(int W = 1, type T = int); endclass
  class drv #(type REQ = base #(2, logic [3:0]), type RSP = base#(.T(byte)));
    REQ req;
    RSP rsp;
  endclass
  typedef drv #(base #(2, logic [3:0])) drv_t;
endpackage
module top; endmodule
