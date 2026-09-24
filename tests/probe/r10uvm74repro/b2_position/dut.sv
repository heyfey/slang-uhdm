// r10uvm74 arm b2 — WHERE IN THE PATH the index sits, and how deep the path is.
//
// The corpus population is entirely BASE-indexed (`args[i].len`,
// `m_override_info[i].ovrd_type_name.len`), so this arm exists to say what
// golden does with the positions the corpus does NOT write: a MIDDLE step, a
// step under an already-indexed base, and two indices in one path.
module b2;
  class leaf;
    string s;
    string sq[$];
  endclass
  class mid;
    leaf   lq[$];
    leaf   l;
    string sq[$];
  endclass

  class user;
    mid    mq[$];
    mid    m;
    int    r;

    function void f(int i, int j);
      // p_base   — index on the BASE step, one member above it (the head)
      r = mq[i].sq.size();
      // p_mid    — base plain, index on a MIDDLE step
      r = m.lq[i].s.len();
      // p_both   — indexed base AND indexed middle
      r = mq[i].lq[j].s.len();
      // p_deep   — indexed base, TWO plain members, then the method
      r = mq[i].l.s.len();
      // p_plain  — NO index anywhere (the pre-existing shape, unchanged)
      r = m.l.s.len();
      // p_last   — the index on the LAST receiver step (directly under method)
      r = m.sq[i].len();
    endfunction
  endclass

  user u;
  initial begin
    u = new();
    u.f(0, 1);
  end
endmodule
