// § pkgTopWidePatReplTsName210 — vw01 (v11u210 break probe): a wide package pattern with TWO replication members of different widths, read WHOLE by its qualified name in a module
package vp;
  typedef struct packed { logic [1:0][63:0] A; logic [3:0][31:0] B; bit E; } s_t;
  localparam s_t S = '{
      A: {2{64'h0}},
      B: {4{32'hDEAD_BEEF}},
      E: 1'b1
  };
endpackage
module dut(output logic [256:0] o);
  assign o = vp::S;
endmodule
