// § tpClsDefaultAtClassName241
package o;
  class base #(int W = 1); endclass
endpackage
package p;
  class drv #(type REQ = o::base #(2));
    REQ req;
  endclass
  typedef drv #(o::base #(2)) drv_t;
endpackage
module top; endmodule
