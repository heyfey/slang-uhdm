// § pureVirtRetAtTypeToken231 — two prototypes of one typedef, and a formal
package p;
  typedef enum { UNKNOWN_ACTION, THROW, CAUGHT} action_e;
  virtual class rc;
    pure virtual function action_e catch();
    pure virtual function action_e catch2(int a, action_e b);
  endclass
endpackage
module top;
endmodule
