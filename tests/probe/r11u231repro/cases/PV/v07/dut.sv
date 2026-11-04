// § pureVirtRetAtTypeToken231 — the prototype written by a macro, and a qualifier list
`define PV(t, n) pure virtual function t n();
package p;
  typedef enum { UNKNOWN_ACTION, THROW, CAUGHT} action_e;
  virtual class rc;
    `PV(action_e, catch)
    pure virtual protected function action_e catch3();
  endclass
endpackage
module top;
endmodule
