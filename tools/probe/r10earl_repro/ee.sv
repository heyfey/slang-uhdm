// r10earl4 ee.sv — gen-scope child ONLY (bb.sv row A alone), to separate the
// § genRefModuleImplicitPort law from bb.sv's second residue (the DEF-view
// port lowConn ref_obj losing its vpiActual).
module echild (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic a,
  output logic o
);
  assign o = a & clk_i & rst_ni;
endmodule

module ee (
  input  logic       clk_i,
  input  logic       rst_ni,
  input  logic [3:0] a,
  output logic [3:0] o
);
  for (genvar i = 0; i < 4; i++) begin : gen_f
    echild u_c (
      .clk_i,
      .rst_ni,
      .a (a[i]),
      .o (o[i])
    );
  end
endmodule
