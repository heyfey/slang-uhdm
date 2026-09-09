// v226 b09 — NESTED process bodies in an uninstantiated interface: named and
// unnamed begin blocks, fork/join, nested loops, a disable, and a block-local
// declared at each depth.  §5's window depth rules, reached through a process.
interface bnest_if;
  int n, m;
  int arr [4];

  initial begin : top_blk
    int t_loc;
    t_loc = 0;
    begin                       // unnamed
      int u_loc;
      u_loc = 1;
      if (u_loc) n = u_loc;     // condition column, unnamed local
      begin : inner_named
        int i_loc;
        i_loc = 2;
        if (i_loc) m = i_loc;   // condition column, NAMED local
      end
    end
    if (t_loc) n = 1;
    fork
      begin
        int f_loc;
        f_loc = 3;
        if (f_loc) m = f_loc;
      end
      m = 4;
    join_none
    while (n < 3) n = n + 1;
    do m = m + 1; while (m < 3);
    forever begin
      int fe;
      fe = 1;
      if (fe) break;
    end
  end

  always_comb begin
    case (n)
      0: m = 0;
      default: m = 1;
    endcase
  end
endinterface
