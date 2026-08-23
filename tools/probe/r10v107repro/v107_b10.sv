// r10v107 arm b10 — WHERE the suppressing typedef/parameter has to live.
// MEASUREMENT ONLY.  Same one shape, ten names; the collision is moved from the
// class's home package to the importing MODULE, to $unit, and to a package the
// module does NOT import.
typedef int td_unit10;             // a $unit typedef
parameter int pm_unit10 = 7;       // a $unit parameter

package other10;                   // NOT imported by the module
  typedef int td_other10;
  parameter int pm_other10 = 9;
endpackage

package pb10;
  typedef int   td_pkg10;
  parameter int pm_pkg10 = 5;

  class d10; int fld; endclass
  class snk10; function int ask(d10 v); return 0; endfunction endclass

  class c10 #(type T = d10);
    snk10 s;
    extern function void n_plain();
    extern function void n_td_pkg();
    extern function void n_td_unit();
    extern function void n_td_other();
    extern function void n_td_mod();
    extern function void n_pm_pkg();
    extern function void n_pm_unit();
    extern function void n_pm_other();
    extern function void n_pm_mod();
    extern function void n_td_iface();
  endclass

  function void c10::n_plain();    T uq10;        if (s.ask(uq10)       == 0) begin end endfunction
  function void c10::n_td_pkg();   T td_pkg10;    if (s.ask(td_pkg10)   == 0) begin end endfunction
  function void c10::n_td_unit();  T td_unit10;   if (s.ask(td_unit10)  == 0) begin end endfunction
  function void c10::n_td_other(); T td_other10;  if (s.ask(td_other10) == 0) begin end endfunction
  function void c10::n_td_mod();   T td_mod10;    if (s.ask(td_mod10)   == 0) begin end endfunction
  function void c10::n_pm_pkg();   T pm_pkg10;    if (s.ask(pm_pkg10)   == 0) begin end endfunction
  function void c10::n_pm_unit();  T pm_unit10;   if (s.ask(pm_unit10)  == 0) begin end endfunction
  function void c10::n_pm_other(); T pm_other10;  if (s.ask(pm_other10) == 0) begin end endfunction
  function void c10::n_pm_mod();   T pm_mod10;    if (s.ask(pm_mod10)   == 0) begin end endfunction
  function void c10::n_td_iface(); T td_iface10;  if (s.ask(td_iface10) == 0) begin end endfunction
endpackage

module topb10;
  import pb10::*;
  typedef int td_mod10;            // the MODULE's own typedef
  parameter int pm_mod10 = 11;     // the MODULE's own parameter
  c10 #(d10) inst;
  initial inst = new();
endmodule
