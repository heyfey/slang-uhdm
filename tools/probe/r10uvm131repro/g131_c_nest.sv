// r10uvm131 arm C — nested forks, a fork carrying a disable, EMPTY forks,
// fork-local declarations, and mismatched/absent end labels.
module ArmCNest;
  int a, b, c;
  initial begin
    // nesting: named outside, unnamed inside and vice versa
    fork : outerN
      begin
        fork
          a = 1;
        join_none
      end
      fork : innerN
        b = 2;
      join_any
    join
    fork
      fork : deepN
        fork
          c = 3;
        join_any
      join_none
      a = 4;
    join_none
    // a fork whose body disables a named block
    fork : killer
      begin
        b = 5;
        disable killer;
      end
    join_none
    // EMPTY forks — Surelog's par_block loop only reaches the join keyword
    // AFTER compiling a statement, so an empty fork may keep vpiJoinType 0.
    fork
    join_none
    fork
    join_any
    fork : emptyNamed
    join_none
    fork : emptyNamed2
    join_any : emptyNamed2
    // fork-local declaration (no initialiser) — the par_block Variables quirk
    fork : holdIt
      int scratch;
      scratch = 6;
    join_any
    // disable fork / wait fork
    fork
      c = 7;
    join_none
    disable fork;
    fork
      a = 8;
    join_none
    wait fork;
  end
endmodule
