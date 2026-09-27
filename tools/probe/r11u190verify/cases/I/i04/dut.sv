// § ifaceWildcardTdNameOrder180 (r11u190: the imported typedefs used only inside an interface function and a modport; the interface is a port of a module)
package p;
  typedef struct packed { logic [3:0] d; } w_t;
  typedef logic [3:0] b_t;
endpackage
interface bus_if;
  import p::*;
  logic [3:0] raw;
  function automatic b_t pick(input w_t x); return x.d; endfunction
  modport mp(input raw, import pick);
endinterface
module user(bus_if.mp m, output logic [3:0] o);
  assign o = m.pick(m.raw);
endmodule
module top(output logic [3:0] o);
  bus_if b();
  user u(b, o);
endmodule
