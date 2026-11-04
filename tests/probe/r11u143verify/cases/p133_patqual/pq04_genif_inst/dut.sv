// § elabPatQualRefQualSpan133
// case pq04: the sub-module with a qualified pattern default instantiated under a generate if
package gq;
  typedef struct packed { int unsigned N; bit M; } g_t;
  localparam g_t G0 = '{N: 7, M: 1'b1};
endpackage
module sub #(parameter gq::g_t P = gq::G0) (output logic [31:0] o);
  assign o = P.N;
endmodule
module top #(parameter bit EN = 1'b1) (output logic [31:0] o);
  if (EN) begin : g
    sub u(.o(o));
  end else begin : h
    assign o = '0;
  end
endmodule
