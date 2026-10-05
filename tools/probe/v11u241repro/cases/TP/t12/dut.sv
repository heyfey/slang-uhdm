// § tpPropDefaultLoc241
package p;
  class outer;
    class inner; endclass
  endclass
  class drv #(type REQ = outer::inner, type RSP = outer);
    REQ req;
    RSP rsp;
  endclass
  typedef drv #(outer::inner, outer) drv_t;
endpackage
module top; endmodule
