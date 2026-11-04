// § tpClsDefaultAtClassName241
package p;
  class base #(int W = 1); endclass
  class drv #(type REQ = base  #(
                                 2));
    REQ req;
    REQ q[$];
  endclass
endpackage
module top; endmodule
