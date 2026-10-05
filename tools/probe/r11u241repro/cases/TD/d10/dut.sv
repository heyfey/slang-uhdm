// § tpPropDefaultLoc241
package p;
  class item; endclass
  class drv #(type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
    REQ arr[$];
    function REQ get(); return req; endfunction
  endclass
  class my_drv extends drv #(item, item);
    function void f(); req = null; endfunction
  endclass
endpackage
module top; endmodule
