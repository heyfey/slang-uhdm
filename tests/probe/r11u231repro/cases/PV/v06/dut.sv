// § pureVirtRetAtTypeToken231 — a class handle return keeps its rule (control)
package p;
  class item;
    int x;
  endclass
  typedef item item_t;
  virtual class rc;
    pure virtual function item get();
    pure virtual function item_t get2();
  endclass
endpackage
module top;
endmodule
