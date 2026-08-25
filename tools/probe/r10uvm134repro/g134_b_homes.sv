// r10uvm134 grid B — HOMES.  The same indexed-root loop list written in a
// class method, an OUT-OF-BODY class method, a package free function, a module
// initial, a module function, an interface and a program.
package qb134;

  class Nut;
    int nv[];
    int nw[string];
  endclass

  class Shell;
    Nut shells[];
    extern function void oob_body();
    function void inbody();
      foreach (shells[h1]) foreach (shells[h1].nv[h2]) $display(h2);
    endfunction
  endclass

  function void Shell::oob_body();
    foreach (shells[h3]) foreach (shells[h3].nw[h4]) $display(h4);
  endfunction

  function automatic void freefn134();
    Nut loc[];
    foreach (loc[h5]) foreach (loc[h5].nv[h6]) $display(h6);
  endfunction

  task automatic freetask134();
    Nut lot[$];
    foreach (lot[h7]) foreach (lot[h7].nw[h8]) $display(h8);
  endtask

endpackage

module mb134;
  qb134::Nut mods[];
  initial begin
    foreach (mods[h9]) foreach (mods[h9].nv[ha]) $display(ha);
  end
  function automatic void modfn();
    qb134::Nut mfl[];
    foreach (mfl[hb]) foreach (mfl[hb].nw[hc]) $display(hc);
  endfunction
endmodule

interface ib134;
  qb134::Nut ifs[];
  function automatic void iffn();
    foreach (ifs[hd]) foreach (ifs[hd].nv[he]) $display(he);
  endfunction
endinterface

program pb134;
  qb134::Nut prs[];
  initial begin
    foreach (prs[hf]) foreach (prs[hf].nw[hg]) $display(hg);
  end
endprogram
