// § ifaceWildcardTdNameOrder180 (r11u190: an interface imports two packages by wildcard; the first-imported package's names sort after the second's)
package zp;
  typedef struct packed { logic a; } z_t;
  typedef logic [3:0] m_t;
endpackage
package ap;
  typedef struct packed { logic b; } a_t;
endpackage
interface bus_if;
  import zp::*;
  import ap::*;
  z_t x;
  a_t y;
  m_t z;
endinterface
module top(output logic o);
  bus_if b();
  assign o = b.x.a;
endmodule
