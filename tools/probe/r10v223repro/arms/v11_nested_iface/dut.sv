// v11 — an interface DECLARED INSIDE A MODULE (nested), importing a package.
package pv11;
  int nv11 = 1;
endpackage

module m_v11;
  import pv11::*;
  logic own_mv11;
  interface if_v11_nested;
    import pv11::*;
    logic own_v11;
  endinterface
  if_v11_nested u_n();
endmodule
