// § pureVirtRetAtTypeToken231 — a package-qualified return type from another package
package p;
  typedef enum { UNKNOWN_ACTION, THROW, CAUGHT} action_e;
endpackage
package q;
  virtual class rc;
    pure virtual function p::action_e catch();
  endclass
endpackage
module top;
endmodule
