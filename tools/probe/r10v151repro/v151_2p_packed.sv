// r10v151 (VERIFIER) arm 2p — PACKED-ARRAY receivers for the KEYWORD reduction
// methods, kept in their OWN file because a tool that refuses them must not
// take the rest of the grid with it.  MEASUREMENT ONLY.
module pmod2;
  bit [7:0] pv8;
  logic [3:0][7:0] pv2d;
  int r2p;
  initial begin
    pv8.and();
    pv8.or();
    pv8.xor();
    pv2d.and();
    r2p = pv8.and();
    if (pv8.xor()) r2p = 3;
  end
endmodule
