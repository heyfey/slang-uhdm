// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  interface class ic;
    pure virtual function void put(UVM_FILE f);
  endclass
  class impl implements ic;
    virtual function void put(UVM_FILE f);
    endfunction
  endclass
  virtual class vb;
    pure virtual function void get(UVM_FILE g);
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
