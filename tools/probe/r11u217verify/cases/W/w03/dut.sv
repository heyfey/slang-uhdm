// § pkgTopWidePatReplTsName210 — r11u217 w03: the wide package pattern read qualified as a CHILD PARAMETER OVERRIDE and in a generate condition, a replication count from a package localparam product
package vp;
  localparam int C1 = 2;
  localparam int C2 = 3;
  typedef struct packed { logic [C1*C2-1:0][15:0] A; bit E; } s_t;
  localparam s_t S = '{
      A: {C1*C2{16'h0}},
      E: 1'b0
  };
endpackage
module ch #(parameter vp::s_t Q = '0) (output logic o);
  assign o = Q.E;
endmodule
module dut(output logic o, output logic q);
  ch #(.Q(vp::S)) u (.o(o));
  if (vp::S.E) begin : g
    assign q = 1'b1;
  end else begin : h
    assign q = 1'b0;
  end
endmodule
