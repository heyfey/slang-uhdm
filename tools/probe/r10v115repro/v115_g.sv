// v115_g — MIRROR HUNT: shapes where golden might KEEP class_var but our
// predicate could now fire.  Every cell is a place the fence could over-reach.
package pg_pkg;
  virtual class base_c;
    virtual function void vf();      // a VIRTUAL in-body method
      process vf_p;
    endfunction
    pure virtual function void pv();
  endclass
  virtual class abs_c extends base_c;   // an ABSTRACT class
    function void af();
      process af_p;
    endfunction
    function void pv(); endfunction
  endclass
  class param_c #(type T = int);     // a PARAMETERISED class
    function void pf();
      process pf_p;                  // in-body method of a parameterised class
    endfunction
    extern function void po();
  endclass
  function void param_c::po();       // OUT-OF-BODY of a parameterised class
    process po_p;
  endfunction
  class use_c;
    param_c #(int) h;
    function void uf();
      process uf_p;
      h = new();
    endfunction
  endclass
endpackage

module mg_top;
  import pg_pkg::*;
  abs_c a_h;
  use_c u_h;
  initial begin
    process mg_p;
    mg_p = process::self();
  end
endmodule
