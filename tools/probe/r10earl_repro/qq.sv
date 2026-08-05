// r10earl6 qq.sv — the prim_clock_inverter class (3 Earlgrey heads:
// dmi_jtag, dmi_jtag_tap, prim_clock_inverter):
//     failLhs operation ''       prim_clock_inverter.sv:18:16
//     failRhs ref_obj  '~clk_i'  :18:16
// prim_clock_inverter.sv:16-22 is
//     if (HasScanMode) begin : gen_scan
//       prim_clock_mux2 i_dft_tck_mux (.clk0_i ( ~clk_i ), ...);
// i.e. a UNARY-OPERATOR port actual on a gen-scope child.  The DEF-view
// gen-block instantiation loop text-parses its actuals and has arms for
// selects, ranges, calls, literals and concats; anything else becomes ONE
// ref_obj NAMED with the raw text, so `~clk_i` came out as a ref_obj called
// "~clk_i".  This witness reads every operator shape that can sit there.
module qchild (
  input        clk0_i,
  input        clk1_i,
  input        sel_i,
  output logic clk_o
);
  assign clk_o = sel_i ? clk1_i : clk0_i;
endmodule

module qq #(
  parameter bit HasScanMode = 1'b1
) (
  input        clk_i,
  input        scanmode_i,
  input        b_i,
  output logic clk_no,
  output logic clk_n2
);

  if (HasScanMode) begin : gen_scan
    // row A — the prim_clock_inverter shape: a PREFIX UNARY actual
    qchild i_dft_tck_mux (
     .clk0_i ( ~clk_i     ),
     .clk1_i ( clk_i      ),
     .sel_i  ( scanmode_i ),
     .clk_o  ( clk_no     )
    );
    // row B — a BINARY actual, and row C a NEGATED one
    qchild i_bin (
     .clk0_i ( clk_i & b_i ),
     .clk1_i ( !b_i        ),
     .sel_i  ( scanmode_i  ),
     .clk_o  ( clk_n2      )
    );
  end else begin : gen_noscan
    logic unused_scanmode;
    assign unused_scanmode = scanmode_i;
    assign clk_no = ~clk_i;
    assign clk_n2 = clk_i;
  end

endmodule
