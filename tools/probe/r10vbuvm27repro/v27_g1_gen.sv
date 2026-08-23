module gen1;
  logic [7:0]   mpk4 [4];
  bit [31:0]    mv32;
  byte unsigned mbe;
  wire [63:0] w0, w1, w2, w3, w4, w5, w6, w7;
  assign w0 = $bits(mpk4[1] & 8'h0F);      // L6  module cont_assign, const idx
  assign w1 = $bits(mpk4[1]);              // L7  single-arg twin
  genvar gv;
  generate
    for (gv = 0; gv < 2; gv++) begin : gblk
      wire [63:0] gw0, gw1, gw2, gw3;
      assign gw0 = $bits(mpk4[gv] & 8'h0F);   // L12 genvar idx, binary
      assign gw1 = $bits(mpk4[gv]);           // L13 genvar idx, single
      assign gw2 = $bits(mpk4[1] & 8'h0F);    // L14 const idx, binary
      assign gw3 = $bits(mpk4[1]);            // L15 const idx, single
    end
  endgenerate
  if (1) begin : cblk
    wire [63:0] cw0, cw1;
    assign cw0 = $bits(mpk4[1] & 8'h0F);   // L20 gen-if, const idx, binary
    assign cw1 = $bits(mpk4[1]);           // L21 gen-if, const idx, single
  end
  initial begin
    logic [63:0] r;
    r = $bits(mpk4[1] & 8'h0F);            // L25 initial
    $display("%0d %0d %0d %0d", r, w0, w1, gblk[0].gw0);
  end
endmodule
