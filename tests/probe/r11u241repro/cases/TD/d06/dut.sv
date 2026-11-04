// § tpPropDefaultLoc241
package p;
  class item; endclass
  class drv #(type REQ = item, type RSP = REQ);
    typedef drv #(REQ, RSP) this_type;
    REQ req;
    RSP rsp;
    function void put(RSP r); rsp = r; endfunction
    extern function void get(output REQ r);
  endclass
  function void drv::get(output REQ r); r = req; endfunction
  typedef drv #(item, item) drv_t;
endpackage
module top; endmodule
