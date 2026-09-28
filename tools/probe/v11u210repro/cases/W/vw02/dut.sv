// § pkgTopWidePatReplTsName210 — vw02 (v11u210 break probe): the wide pattern read by its qualified name ONLY as an instance parameter override
package vp;
  typedef struct packed { logic [3:0][63:0] A; bit E; } s_t;
  localparam s_t S = '{ A: {4{64'h0}}, E: 1'b1 };
endpackage
module sub #(parameter vp::s_t P = '0) (output logic o);
  assign o = P.E;
endmodule
module dut(output logic p);
  sub #(.P(vp::S)) u(.o(p));
endmodule
