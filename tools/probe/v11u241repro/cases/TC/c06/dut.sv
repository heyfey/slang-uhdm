// § tpClsDefaultAtClassName241
package p;
  class base #(int W = 1); endclass
  class drv #(type REQ = base #(2));
    REQ req;
  endclass
endpackage
module top;
  p::drv #(p::base #(2)) a;
  p::drv b;
endmodule
