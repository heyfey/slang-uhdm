// r10vbuvm27 ARM F -- § genBlockBitsNoLeftmostFold27v.
// SURELOG NEVER FOLDS `$bits` INSIDE A GENERATE BLOCK; the SAME text one line
// outside the block folds.  Every cell below was read from the pinned Surelog
// (LHS is always golden).  f01..f12 KEEP in golden; f20..f23 FOLD in golden.
// A module INSTANTIATED inside a generate block is unaffected (f22): its own
// body folds, so the test is LEXICAL, not instance-path.
interface ifF;
  logic [7:0] ipk [4];
  wire [63:0] iw0, iw1;
  for (genvar gi = 0; gi < 2; gi++) begin : ig
    wire [63:0] igw;
    assign igw = $bits(ipk[1] & 8'h0F);      // f01 interface for-generate   KEEP
  end
  assign iw0 = $bits(ipk[1] & 8'h0F);        // f20 interface top            FOLD 32
  assign iw1 = $bits(ipk[1]);                // f21 single-arg twin          FOLD 32
endinterface

module childF;
  logic [7:0] cpk [4];
  wire [63:0] cw;
  assign cw = $bits(cpk[1] & 8'h0F);         // f22 own body, even when instantiated
endmodule                                    //     inside a generate block   FOLD 32

module v27_f_gen;
  logic [7:0]   mpk [4];
  byte unsigned mbe;
  int mr;
  wire [63:0] mw;
  ifF u_if();

  // ---- for-generate: every carrier inside the block
  for (genvar gv = 0; gv < 2; gv++) begin : gblk
    wire [63:0] gw;
    int gr;
    assign gw = $bits(mpk[1] & 8'h0F);                       // f02 cont_assign KEEP
    initial gr = $bits(mpk[1] & 8'h0F);                      // f03 initial     KEEP
    always @(mbe) gr = $bits(mpk[1] & 8'h0F);                // f04 always      KEEP
    function int gf(); return $bits(mpk[1] & 8'h0F); endfunction // f05 function KEEP
    assign gw[7:0] = $bits(mpk[gv] & 8'h0F);                 // f06 genvar index KEEP
    childF u_c();                                            // f22 lives here
  end

  // ---- if-generate, case-generate, bare generate block, nested generate
  if (1) begin : cblk
    wire [63:0] cw;
    assign cw = $bits(mpk[1] & 8'h0F);                       // f07 if-generate  KEEP
  end
  case (1)
    1: begin : sblk
      wire [63:0] sw;
      assign sw = $bits(mpk[1] & 8'h0F);                     // f08 case-generate KEEP
    end
  endcase
  generate
    begin : bblk
      wire [63:0] bw;
      assign bw = $bits(mpk[1] & 8'h0F);                     // f09 bare block   KEEP
    end
    for (genvar ov = 0; ov < 2; ov++) begin : oblk
      for (genvar iv = 0; iv < 2; iv++) begin : iblk
        wire [63:0] nw;
        assign nw = $bits(mpk[1] & 8'h0F);                   // f10 nested       KEEP
      end
    end
  endgenerate

  // ---- the SAME text outside every generate block
  assign mw = $bits(mpk[1] & 8'h0F);                         // f23 module top   FOLD 32
  initial begin
    mr = $bits(mpk[1] & 8'h0F);                              // f24 module initial FOLD 32
    $display("%0d %0d %0d %0d", mr, mw, u_if.iw0, gblk[0].gr);
  end
endmodule
