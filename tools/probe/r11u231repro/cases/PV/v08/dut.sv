// § pureVirtRetAtTypeToken231 — a derived class implements the pure virtual
package p;
  typedef enum { UNKNOWN_ACTION, THROW, CAUGHT} action_e;
  virtual class rc;
    pure virtual function action_e catch();
  endclass
  class my_rc extends rc;
    virtual function action_e catch();
      return THROW;
    endfunction
  endclass
endpackage
module top;
  initial begin
    p::my_rc r = new;
    void'(r.catch());
  end
endmodule
