// § tpPropDefaultLoc241
package p;
  class item; endclass
  class drv #(type REQ = item, type RSP = REQ);
    REQ req;
    RSP rsp;
    function void set(REQ r); req = r; endfunction
    function RSP get(); return rsp; endfunction
  endclass
endpackage
module top;
  import p::*;
  drv #(item, item) a;
  drv b;
  initial begin a = new(); b = new(); end
endmodule
