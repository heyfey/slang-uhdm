// v16 — the § oobCtorLocalsRideTheImport203 interaction on the INTERFACE
// road: the imported package holds a class with an OUT-OF-BODY constructor
// whose body locals Surelog leaves in the package's variable listing.
package pv16;
  int pv16a = 1;
  class cv16;
    int m;
    extern function new(input int a);
  endclass
  function cv16::new(input int a);
    int loc16a;
    string loc16b;
    begin
      int loc16c;
      loc16c = a;
    end
    m = a;
  endfunction
  int pv16b = 2;
endpackage

interface if_v16;
  import pv16::*;
  logic own_v16;
endinterface

module m_v16;
  import pv16::*;
  logic own_mv16;
endmodule
