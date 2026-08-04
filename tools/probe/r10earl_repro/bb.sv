// r10earl4 bb.sv — § genRefModuleImplicitPort.
// A module DEF view lists each gen-scope child as a ref_module carrying one
// vpiPort per CONNECTION.  Earlgrey heads (tlul_socket_1n gen_dfifo/fifo_d 7,
// prim_diff_decode gen_async/i_sync_p 5, gpio gen_filter/filter, nmi_gen
// gen_esc_sev) all read "golden ports=N, ours=N-2" and the two missing rows
// are the IMPLICIT `.name` connections (`.clk_i,` / `.rst_ni,` with no
// parenthesised actual).  Row B is the same instance OUTSIDE a gen block, as
// the control.
module bchild (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic a,
  output logic o
);
  assign o = a & clk_i & rst_ni;
endmodule

module bb (
  input  logic       clk_i,
  input  logic       rst_ni,
  input  logic [3:0] a,
  output logic [3:0] o,
  output logic       o2
);
  // A: gen-scope child with two IMPLICIT connections and two explicit ones
  for (genvar i = 0; i < 4; i++) begin : gen_f
    bchild u_c (
      .clk_i,
      .rst_ni,
      .a (a[i]),
      .o (o[i])
    );
  end
  // B: the same child OUTSIDE any gen block (control)
  bchild u_flat (
    .clk_i,
    .rst_ni,
    .a  (a[0]),
    .o  (o2)
  );
endmodule
