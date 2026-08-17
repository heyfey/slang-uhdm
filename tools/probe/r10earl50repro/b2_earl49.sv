// b2: the SAME read-shape grid with the bound taken from a PACKAGE parameter.
package b2p;
  parameter int W = 32;
endpackage
module b2_earl49 #(
  parameter logic [b2p::W-1:0] P1 = 'h0,
  parameter logic [b2p::W-1:0] P2 = 'h0,
  parameter logic [b2p::W-1:0] P3 = 'h0,
  parameter logic [b2p::W-1:0] P4 = 'h0,
  parameter logic [b2p::W-1:0] P5 = 'h0,
  parameter logic [b2p::W-1:0] P6 = 'h0
) (
  input  logic                   c,
  input  logic [b2p::W-1:0]      n,
  output logic [b2p::W-1:0]      o1, o2, o3, o4, o5
);
  assign o1 = P1 | {{(b2p::W-4){1'b0}}, n[3:0]};
  assign o2 = P2;
  assign o3 = P3 & n;
  for (genvar k = 0; k < 32; k++) begin : gen_j
    assign o4[k] = c ? P4[k] : n[k];
  end
  if (b2p::W > 0) begin : gen_l
    assign o5 = P5[b2p::W-1:0];
  end
endmodule
