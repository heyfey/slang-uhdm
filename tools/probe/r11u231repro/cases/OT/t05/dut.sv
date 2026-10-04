// § oobClassTdFirstClassKey231 — a class-scoped typedef of another name in two classes
package p;
  class aa;
    typedef logic [3:0] item_t;
  endclass
  class bb;
    typedef logic [7:0] item_t;
    extern function void put(item_t v);
  endclass
  function void bb::put(item_t v);
  endfunction
endpackage
module top;
endmodule
