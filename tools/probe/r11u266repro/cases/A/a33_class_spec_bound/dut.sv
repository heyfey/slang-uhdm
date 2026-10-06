// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  class C #(parameter int W = 2);
    static function int w(); return W; endfunction
  endclass
endpackage
module sub #(parameter q::m_t M = '0) (input logic [15:0] x, output logic [1:0] o);
  assign o = x[q::C#(2)::w() - 1 + M[0] : M[0]];
endmodule
module dut (input logic [15:0] x, output logic [1:0] o);
  sub #(.M(8'h0)) u (.x(x), .o(o));
endmodule
