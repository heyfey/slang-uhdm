module gen2;
  logic [7:0]   mpk4 [4];
  byte unsigned mbe;
  int mr;
  genvar gv;
  generate
    for (gv = 0; gv < 2; gv++) begin : gblk
      localparam int GLP  = $bits(mpk4[1] & 8'h0F);  // L8  gen localparam binary
      localparam int GLP2 = $bits(mpk4[1]);          // L9  gen localparam single
      wire [63:0] gw;
      int gr;
      assign gw = $bits(mpk4[1] & 8'h0F);            // L12 gen cont_assign
      initial gr = $bits(mpk4[1] & 8'h0F);           // L13 gen initial
      always @(mbe) gr = $bits(mpk4[1] & 8'h0F);     // L14 gen always
      function int gf(); return $bits(mpk4[1] & 8'h0F); endfunction  // L15 gen function
      initial gr = gf() + GLP + GLP2;
    end
  endgenerate
  initial begin
    mr = $bits(mpk4[1] & 8'h0F);                     // L20 module initial
    $display("%0d %0d", mr, gblk[0].gr);
  end
endmodule
