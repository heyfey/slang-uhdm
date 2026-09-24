// r10uvm81 arm c7 — a FAITHFUL MINIATURE of BuildUVMPkg's `uvm_init`, the one
// corpus cell whose `if` CONDITION takes the PACKAGE VARIABLE where arm c6's
// every `if` condition keeps the formal.  Reproduced statement for statement so
// the exception is MEASURED rather than argued.
//
//   function void uvm_init(uvm_coreservice_t cs=null);
//     uvm_default_coreservice_t dcs;
//     if(get_core_state()!=UVM_CORE_UNINITIALIZED) begin
//       if (get_core_state() == UVM_CORE_PRE_INIT) begin ... end
//       else begin
//         uvm_coreservice_t actual;
//         actual = uvm_coreservice_t::get();
//         if ((cs != actual) && (cs != null))   <- takes uvm_pkg::cs
//           begin ... end
//       end
//       return;
//     end
//     ...
//     if(cs == null) begin                      <- keeps the io_decl
//       dcs = new();
//       cs = dcs;                               <- takes uvm_pkg::cs
//     end
package p87;
  int sink;
  int state;
  class c87;
    string m_s;
    extern function new();
  endclass
  function c87::new();
    begin
      string val;
      val = "x";
      m_s = val;
    end
  endfunction

  function void gi87(int val);
    int dcs;
    if (state != 0) begin
      if (state == 1) begin
        dcs = 1;
        sink = dcs;
      end
      else begin
        int actual;
        actual = 2;
        if ((val != actual) && (val != 0))   // F1  uvm_init 9812 verbatim
          sink = 3;
      end
      return;
    end
    state = 4;
    if (val == 0) begin                      // F2  uvm_init 9827 verbatim
      dcs = 5;
      val = dcs;                             // F3  uvm_init 9829 verbatim
    end
    sink = val;                              // F4  uvm_init 9831's shape
  endfunction

  // The SAME `if` condition shape, but WITHOUT the enclosing two begins.
  function void gj87(int val);
    int actual;
    actual = 2;
    if ((val != actual) && (val != 0))       // F5  depth-2 cond, TOP LEVEL
      sink = 6;
    if (val == 0)                            // F6  depth-1 cond, TOP LEVEL
      sink = 7;
  endfunction

  // ...and ONE begin deep, with a local declared in that begin.
  function void gk87(int val);
    begin
      int actual;
      actual = 2;
      if ((val != actual) && (val != 0))     // F7  depth-2 cond, ONE begin deep
        sink = 8;
      if (val == 0)                          // F8  depth-1 cond, ONE begin deep
        sink = 9;
    end
  endfunction
endpackage

// --- the DEPTH ladder, plain `begin`s, one `if` condition per level ---
package p88;
  int sink;
  class c88;
    string m_s;
    extern function new();
  endclass
  function c88::new();
    begin
      string val;
      val = "x";
      m_s = val;
    end
  endfunction

  function void gd88(int val);
    if (val == 0) sink = 1;                       // G0 depth 0 (function body)
    begin
      if (val == 0) sink = 2;                     // G1 depth 1
      begin
        if (val == 0) sink = 3;                   // G2 depth 2
        begin
          if (val == 0) sink = 4;                 // G3 depth 3
        end
      end
    end
  endfunction

  // the same ladder built out of IF-BRANCH begins instead of plain ones
  function void ge88(int val);
    if (sink == 0) begin
      if (sink == 1) begin
        if (val == 0) sink = 5;                   // H2 depth 2 (if-branch begins)
      end
    end
  endfunction

  // and a ladder of FORK / FOR / WHILE bodies
  function void gf88(int val);
    for (int i = 0; i < 2; i++) begin
      if (val == 0) sink = 6;                     // I1 depth 1 inside a for body
      begin
        if (val == 0) sink = 7;                   // I2 depth 2
      end
    end
  endfunction
endpackage
