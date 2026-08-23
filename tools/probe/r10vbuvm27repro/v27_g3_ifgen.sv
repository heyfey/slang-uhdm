interface ifg;
  logic [7:0] ipk [4];
  byte unsigned ibe;
  wire [63:0] iw;
  genvar gi;
  for (gi = 0; gi < 2; gi++) begin : ig
    wire [63:0] igw;
    assign igw = $bits(ipk[1] & 8'h0F);      // L8 interface gen scope
  end
  assign iw = $bits(ipk[1] & 8'h0F);          // L10 interface top
endinterface
module child;
  logic [7:0] cpk [4];
  byte unsigned cbe;
  wire [63:0] cw;
  assign cw = $bits(cpk[1] & 8'h0F);          // L16 child module top
endmodule
module gen3;
  logic [7:0] mpk [4];
  wire [63:0] mw;
  ifg u_if();
  genvar gv;
  for (gv = 0; gv < 2; gv++) begin : gb
    child u_c();                              // L24 module instance in gen scope
  end
  assign mw = $bits(mpk[1] & 8'h0F);          // L26
  class CM;
    logic [7:0] kpk [4];
    byte unsigned kbe;
    function int km(); return $bits(kpk[1] & kbe); endfunction   // L30 class at module scope
  endclass
  initial begin
    CM c = new();
    $display("%0d %0d %0d", mw, c.km(), u_if.iw);
  end
endmodule
