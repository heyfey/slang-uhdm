// v119 arm G — MACRO-EXPANDED member randomize (the corpus's own shape) and
// naming stress.  Names, case, length, count and order all vary; nothing is
// a_t/b_t/c_t over A/B/C.
`define TRY_G(RECV, C) \
  if (!RECV.randomize() with C) begin zzz = zzz + 1; end

`define TRY2_G(RECV) \
  if (!RECV.randomize() with { Bee > 2; }) begin zzz = zzz + 2; end

class Bee_holder_g;
  rand int unsigned Bee;
  rand int unsigned q7;
endclass

class m_long_receiver_name_9_holder_g;
  rand int unsigned Bee;
  rand int unsigned q7;
endclass

class one_site_g;
  Bee_holder_g a;
  int unsigned zzz;
  task go();
    `TRY_G(a, { Bee > 1; })
  endtask
endclass

class two_sites_g;
  m_long_receiver_name_9_holder_g m_long_receiver_name_9;
  Bee_holder_g X;
  int unsigned zzz;
  task go();
    `TRY2_G(X)
    `TRY_G(m_long_receiver_name_9, { q7 < 8; })
  endtask
endclass

class three_sites_g;
  Bee_holder_g q7_recv;
  Bee_holder_g ZZ;
  Bee_holder_g a1;
  int unsigned zzz;
  task go();
    // written order deliberately unlike the declaration order
    `TRY_G(ZZ, { q7 > 3; })
    if (!a1.randomize() with { Bee != 4; }) zzz = zzz + 3;
    `TRY_G(q7_recv, { Bee < 5; })
  endtask
endclass

module top_g2;
  one_site_g s1;
  two_sites_g s2;
  three_sites_g s3;
  initial begin
    s1 = new(); s2 = new(); s3 = new();
    s1.go(); s2.go(); s3.go();
  end
endmodule
