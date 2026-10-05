// § tpPropDefaultLoc241
package p;
  class item; endclass
  class drv #(type REQ = item, int N = 2, type RSP = REQ);
    REQ req;
    RSP rsp;
    function void f();
      REQ loc;
      loc = req;
    endfunction
  endclass
endpackage
package q;
  import p::*;
  typedef drv #(item, 2, item) drv_t;
endpackage
module top; endmodule
