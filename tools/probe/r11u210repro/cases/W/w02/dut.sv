// § pkgTopWidePatReplTsName210 — w02: the replication count a package localparam, the pattern read by a qualified name in two modules
package vp;
  localparam int CNT = 4;
  typedef struct packed { logic [CNT-1:0][63:0] A; bit E; } s_t;
  localparam s_t S = '{
      A: {CNT{64'h0}},
      E: 1'b1
  };
endpackage
module sub(output logic o);
  assign o = vp::S.E;
endmodule
module dut(output logic o, output logic p);
  assign o = vp::S.E;
  sub u(.o(p));
endmodule
