// b1: READ-SHAPE grid, bound = the module's OWN parameter.
// Each Pn is read in exactly one shape; P6 is read nowhere.
module b1_earl49 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] P1 = 'h0,   // OR with a concat holding a net  (sram2tlul)
  parameter logic [W-1:0] P2 = 'h0,   // whole name IS the RHS
  parameter logic [W-1:0] P3 = 'h0,   // AND with a bare net
  parameter logic [W-1:0] P4 = 'h0,   // select in a ternary BRANCH inside a for-generate (jtag_mux)
  parameter logic [W-1:0] P5 = 'h0,   // part-select IS the RHS inside an if-generate (prim_lfsr)
  parameter logic [W-1:0] P6 = 'h0    // never read
) (
  input  logic           c,
  input  logic [W-1:0]   n,
  output logic [W-1:0]   o1, o2, o3, o4, o5
);
  assign o1 = P1 | {{(W-4){1'b0}}, n[3:0]};
  assign o2 = P2;
  assign o3 = P3 & n;
  for (genvar k = 0; k < 32; k++) begin : gen_j
    assign o4[k] = c ? P4[k] : n[k];
  end
  if (W > 0) begin : gen_l
    assign o5 = P5[W-1:0];
  end
endmodule
