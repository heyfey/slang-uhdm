// § pkgTopWidePatReplTsName210 — r11u217 w02: the wide package pattern read BOTH qualified (`vp::S.E`) in one module and unqualified through a wildcard import in another, with two replication members (one a nonzero value)
package vp;
  typedef struct packed { logic [3:0][63:0] A; logic [1:0][31:0] B; bit E; } s_t;
  localparam s_t S = '{
      A: {4{64'h0}},
      B: {2{32'h5}},
      E: 1'b1
  };
endpackage
module sub import vp::*; (output logic o);
  assign o = S.E;
endmodule
module dut(output logic o, output logic p);
  assign o = vp::S.E;
  sub u(.o(p));
endmodule
