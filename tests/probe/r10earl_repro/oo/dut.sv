// r10earl6 oo.sv — the UNKNOWN-MODULE ref_module stub (3 Earlgrey heads,
// DECODED in the pass-4/5 census and never implemented):
//     BUFGCE  u_bufgce   {def='work@BUFGCE'  actual=<null> ports=3}
//     BUFGMUX bufgmux_i  {def='work@BUFGMUX' actual=<null> ports=4}
//     IOBUF   i_iobuf    {def='work@IOBUF'   actual=<null> ports=4}
// i.e. golden's module DEF listing carries a ref_module for an instantiation
// of a module with NO definition anywhere: VpiName = the INSTANCE name,
// VpiDefName = `work@<TYPE>`, Actual_module NULL, and the port vector = the
// written connections.  All three sit at PLAIN module scope.
//
// THE SHAPE MATTERS: slang REJECTS `BUFGCE u_bufgce(...)` outright
// ("unknown module") wherever it actually elaborates the instantiation, so
// the Earlgrey trio survive only because their prim_xilinx_* modules are
// reached ONLY through an untaken `Impl == ImplXilinx` generate arm — the
// § uninstDefPortedAdmit population, where slang builds the body with
// createDefault and the child becomes an UninstantiatedDefSymbol instead.
// The witness must reproduce THAT: ochild/ochild2 are instantiated ONLY in
// the untaken arm.  Leaving them uninstantiated does NOT work — slang then
// promotes each to a TOP and elaborates it, and the error comes back.

// row A — the prim_xilinx_clock_gating shape (3 named conns, one of them an
// operation) in a module nothing instantiates
module ochild (
  input        clk_i,
  input        en_i,
  input        test_en_i,
  output logic clk_o
);
  BUFGCE u_bufgce (
    .I  (clk_i),
    .CE (en_i | test_en_i),
    .O  (clk_o)
  );
endmodule

// row B — the prim_xilinx_pad_wrapper shape (4 conns incl. a literal), and a
// SECOND unknown instantiation in the same def so the port vectors separate
module ochild2 (
  input  logic a_i,
  inout  wire  io_o,
  output logic z_o
);
  IOBUF i_iobuf (
    .T  (a_i),
    .I  (1'b0),
    .O  (z_o),
    .IO (io_o)
  );
  BUFGMUX bufgmux_i (
    .I0 (a_i),
    .I1 (1'b0),
    .S  (a_i),
    .O  (z_o)
  );
endmodule

typedef enum integer {ImplGeneric, ImplXilinx} impl_e;

module oo #(
  parameter impl_e Impl = ImplGeneric
) (input logic clk_i, input logic a_i, output logic z_o);
  if (Impl == ImplXilinx) begin : gen_xilinx
    ochild2 u_x (.a_i(a_i), .io_o(), .z_o(z_o));
    ochild  u_g (.clk_i(clk_i), .en_i(a_i), .test_en_i(1'b0), .clk_o());
  end else begin : gen_generic
    assign z_o = a_i ^ clk_i;
  end
endmodule
