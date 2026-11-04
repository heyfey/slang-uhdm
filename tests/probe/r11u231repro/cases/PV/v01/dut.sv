// § pureVirtRetAtTypeToken231 — a pure virtual function returning a package enum typedef (uvm_report_catcher::catch)
package p;
  typedef enum { UNKNOWN_ACTION, THROW, CAUGHT} action_e;
  virtual class rc;
    pure virtual function action_e catch();
  endclass
endpackage
module top;
endmodule
