// § pureVirtRetAtTypeToken231 — a signed and a packed-dimension typedef return
package p;
  typedef logic signed [7:0] sb_t;
  typedef bit [1:0][3:0] pk_t;
  virtual class rc;
    pure virtual function sb_t f1();
    pure virtual function pk_t f2();
  endclass
endpackage
module top;
endmodule
