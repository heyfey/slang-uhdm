// § enumAliasClone161 — an interface enum aliased in the interface, the alias variable driven through a modport
interface m_if;
  typedef enum logic [1:0] { S0 = 2'd0, S1 = 2'd3 } st_e;
  typedef st_e st_t;
  st_t cur;
  modport drv(output cur);
endinterface
module drv_m(m_if.drv p);
  assign p.cur = p.S1;
endmodule
module top(output logic [1:0] o);
  m_if b();
  drv_m d(.p(b));
  assign o = b.cur;
endmodule
