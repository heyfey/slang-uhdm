// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  class K;
    m_t v;
    function void set(m_t a); this.v = a; endfunction
  endclass
endpackage
module sub #(parameter q::m_t M = '0) (output logic [7:0] o);
  initial begin
    automatic q::K k = new;
    k.set(M);
  end
  assign o = 8'h0;
endmodule
module dut (output logic [7:0] o);
  sub #(.M(8'h3c)) u (.o(o));
endmodule
