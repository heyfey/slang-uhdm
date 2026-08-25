// r10v126 arm E - EDGE KEYWORDS and the time/signing fix's own control.
// `realtime` (Surelog's `default:` row -> logic_typespec), `time` x signing
// again in a DIFFERENT home and order, a string array in a module task, and a
// packed-control triple that must not move.
package pk_edg126v;
  class Edge126v;
    function int measure();
      realtime  rt_arr126v [3];
      time      tm_bare126v [2];
      time signed tm_sgn126v [4];
      time unsigned tm_uns126v [5];
      real      rl_arr126v [6];
      shortreal sr_arr126v [7];
      string    st_arr126v [2];
      logic [3:0] ctl_a126v [3];
      bit   [1:0] ctl_b126v [4];
      int         ctl_c126v [5];
      rt_arr126v[2] = 1.5; tm_bare126v[1] = 3; tm_sgn126v[3] = 4;
      tm_uns126v[4] = 5; rl_arr126v[5] = 2.5; sr_arr126v[6] = 3.5;
      st_arr126v[1] = "e"; ctl_a126v[2] = 4'h7; ctl_b126v[3] = 2'd1;
      ctl_c126v[4] = 8;
      return 0;
    endfunction
  endclass
endpackage
module m_edg126v;
  task modStrTsk126v();
    string  mstr126v [3];
    time signed mts126v [2];
    realtime mrt126v [4];
    mstr126v[2] = "m"; mts126v[1] = 6; mrt126v[3] = 4.5;
  endtask
  initial modStrTsk126v();
endmodule
