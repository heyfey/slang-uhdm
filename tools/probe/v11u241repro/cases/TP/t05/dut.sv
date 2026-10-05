// § tpPropDefaultLoc241
class item; endclass
class other; endclass
class drv #(type REQ = item, type RSP = REQ);
  REQ req;
  RSP rsp;
  function REQ get(); return req; endfunction
endclass
typedef drv #(other) a_t;
typedef drv #(item, item) b_t;
module top; endmodule
