// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  virtual class B;
    pure virtual function m_t f(m_t a);
    extern function m_t g(m_t a);
  endclass
  function m_t B::g(m_t a); return a; endfunction
endpackage
module sub #(parameter q::m_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o);
  sub #(.M(8'h3c)) u (.o(o));
endmodule
