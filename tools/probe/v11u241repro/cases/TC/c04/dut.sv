// § tpClsDefaultAtClassName241
package p;
  class inner #(int N = 0); endclass
  class base #(type T = int); endclass
  class drv #(type REQ = base #(inner #(3)));
    REQ req;
  endclass
  typedef drv #(base #(inner #(3))) drv_t;
endpackage
module top; endmodule
