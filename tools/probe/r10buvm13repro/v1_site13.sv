// r10buvm13 arm v1 — THE SITE MATRIX for a FORMAL'S DEFAULT VALUE.
// One question per cell: does a ref written inside a formal's default value
// carry vpiActual, and of what kind?
// Axes: package free function / package free task / IN-BODY class method /
// class extern PROTOTYPE listing / its OUT-OF-BODY DEFINITION / pure virtual
// prototype, crossed with what the default names: an EARLIER FORMAL, an ENUM
// CONSTANT, a PACKAGE VARIABLE, a PACKAGE PARAMETER, a LOCALPARAM and a CALL.
package p13;
  typedef enum int {E13_A = 1, E13_B = 2, E13_C = 3} e13_t;
  int pkgvar13 = 7;
  parameter int PK13 = 3;
  localparam int LK13 = 5;

  function int pf_ret(); return 1; endfunction

  // ---- package FREE FUNCTION / TASK -------------------------------------
  function int pf_earlier(int a, int b = a);              return a + b; endfunction
  function int pf_enum   (e13_t e = E13_B);               return int'(e); endfunction
  function int pf_pkgvar (int v = pkgvar13);              return v; endfunction
  function int pf_param  (int v = PK13);                  return v; endfunction
  function int pf_local  (int v = LK13);                  return v; endfunction
  function int pf_call   (int v = pf_ret());              return v; endfunction
  // an ENUM CONSTANT reaching a BUILT-IN keyword type -- the spelling UVM uses
  // (`int verbosity = UVM_MEDIUM`), the one § noDirNamedTypeDefaultDropped30
  // KEEPS.  The `e13_t e = E13_B` spellings above are dropped by Surelog and
  // so carry no cell at all; that is why they are written too.
  function int pf_enumi  (int v = E13_B);                 return v; endfunction
  function int pf_mix    (int a, int b = a + PK13 + LK13); return a + b; endfunction
  task pt_earlier(input int a, input int b = a);          endtask
  task pt_enum   (input e13_t e = E13_C);                 endtask

  // ---- IN-BODY class methods --------------------------------------------
  class c13;
    int prop13 = 4;
    function int m_earlier(int a, int b = a);             return a + b; endfunction
    function int m_enum   (e13_t e = E13_B);              return int'(e); endfunction
    function int m_param  (int v = PK13);                 return v; endfunction
    function int m_local  (int v = LK13);                 return v; endfunction
    function int m_pkgvar (int v = pkgvar13);             return v; endfunction
    task m_task(input int a, input int b = a);            endtask
    function int m_enumi  (int v = E13_B);                return v; endfunction
    // an extern PROTOTYPE listing and its OUT-OF-BODY DEFINITION
    extern function int x_earlier(int a, int b = a);
    extern function int x_enum(e13_t e = E13_B);
    extern task x_task(input int a, input int b = a);
    extern function int x_enumi(int v = E13_B);
  endclass
  function int c13::x_earlier(int a, int b = a);          return a + b; endfunction
  function int c13::x_enum(e13_t e = E13_B);              return int'(e); endfunction
  task c13::x_task(input int a, input int b = a);         endtask
  function int c13::x_enumi(int v = E13_B);               return v; endfunction

  // ---- pure virtual PROTOTYPE (no body at all) --------------------------
  virtual class v13;
    pure virtual function int v_earlier(int a, int b = a);
    pure virtual function int v_enum(e13_t e = E13_B);
    pure virtual function int v_enumi(int v = E13_B);
  endclass
endpackage

module m13_top;
  import p13::*;
  initial begin
    automatic int z = pf_earlier(1);
    z = pf_enum();
    z = pf_pkgvar();
    z = pf_param();
    z = pf_local();
    z = pf_call();
    z = pf_enumi();
    z = pf_mix(1);
    pt_earlier(1);
    pt_enum();
  end
endmodule
