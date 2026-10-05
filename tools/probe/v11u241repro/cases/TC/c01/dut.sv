// § tpClsDefaultAtClassName241
package p;
  class base #(int W = 1); endclass
  class drv #(type REQ = base #( .W(2) ));
    REQ req;
  endclass
  typedef drv #(base #(2)) drv_t;
endpackage
module top; endmodule
