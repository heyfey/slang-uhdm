// § tpPropDefaultLoc241
`define DEFT item
package p;
  class item; endclass
  class drv #(type REQ = `DEFT, type RSP = REQ);
    REQ req;
    RSP rsp;
  endclass
  class user;
    drv #(item, item) d;
    drv #(`DEFT) e;
  endclass
endpackage
module top; endmodule
