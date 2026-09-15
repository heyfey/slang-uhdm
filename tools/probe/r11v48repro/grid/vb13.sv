// vb13 — the bound inside a GENERATE block and inside an INTERFACE.
interface vb13i (input logic c);
  localparam int          PS = 4;
  localparam int unsigned PU = 4;
  logic [PS:0] xs;
  logic [PU:0] xu;
endinterface
module vb13 (input logic c, output logic o);
  localparam int          GS = 4;
  localparam int unsigned GU = 4;
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gb
      logic [GS:0] ys;
      logic [GU:0] yu;
      assign ys = '0;
      assign yu = '0;
    end
  endgenerate
  assign o = c ^ gb[0].ys[0] ^ gb[1].yu[0];
endmodule
