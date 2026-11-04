// § tpClsDefaultAtClassName241
package p;
  class base #(int W = 1); endclass
  class drv #(type REQ = base #(2));
    REQ req;
    REQ q[$];
  endclass
  typedef drv #(base #(2)) drv_t;
endpackage
module top; endmodule
