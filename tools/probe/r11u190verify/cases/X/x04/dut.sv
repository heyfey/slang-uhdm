// § ifaceWildcardTdNameOrder180 § doWhileMacroCondEnd181 (r11u190 cross: interface typedefs from a wildcard import used in a do-while macro condition of an interface task)
`define NOTDONE(s) (s.cnt < 4'd9)
package p;
  typedef struct packed { logic [3:0] cnt; } st_t;
  typedef struct packed { logic go; } ctl_t;
endpackage
interface bus_if;
  import p::*;
  st_t st;
  ctl_t ctl;
  task automatic run();
    do st.cnt++; while `NOTDONE(st);
  endtask
endinterface
module top;
  bus_if b();
  initial b.run();
endmodule
