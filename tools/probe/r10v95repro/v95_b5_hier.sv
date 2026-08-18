// r10v95 arm b5 — HIERARCHICAL / cross-instance select arguments, 1..3
// instances of the same leaf so an instance-count effect would show.
module leaf5 #(parameter int LW = 8) ();
  logic [LW-1:0] lbus;
  byte           larr [3];
  byte           ldyn [];
endmodule

module mid5;
  leaf5 #(.LW(20)) u_a ();
  leaf5 #(.LW(12)) u_b ();
  leaf5            u_c ();
  int h [12];
  initial begin
    h[0] = $bits(u_a.lbus);
    h[1] = $bits(u_a.lbus[3]);
    h[2] = $bits(u_a.lbus[7:2]);
    h[3] = $bits(u_a.larr);
    h[4] = $bits(u_a.larr[1]);
    h[5] = $bits(u_a.ldyn[0]);
    h[6] = $bits(u_b.lbus[1]);
    h[7] = $bits(u_c.larr[2]);
  end
endmodule

module b5;
  mid5 m0 ();
endmodule
