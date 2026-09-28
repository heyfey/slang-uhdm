  struct packed { in_t mhdr; } h;
  always_comb h = d;
  assign o2 = h.mhdr.b;
