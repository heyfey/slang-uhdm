// g9 — cfg_func_width_loop's exact chain, reduced: a package function whose
// body calls another with a FOR-LOOP LOCAL, called through a MODULE PARAMETER
// so the def listing cannot fold and the elab listing can.  The faithful
// repro of the corpus head (g6 reproduces it from the other side).
package g9p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned maxw(logic [2:0] cfg);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < 3; i++)
      if (cfg[i])
        if (w(i) > res) res = w(i);
    return res;
  endfunction
endpackage
module g9sub #(parameter logic [2:0] M = '0) (output logic [g9p::maxw(M)-1:0] b);
  assign b = '0;
endmodule
module g9 (output logic [3:0] o);
  g9sub #(.M(3'b101)) u (.b(o));
endmodule
