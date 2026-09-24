// g2 — cfg_func_width_loop shape (THE HEAD): a package function body calling
// another with a FOR-LOOP LOCAL as the actual.
package g2p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned maxw(int unsigned n);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < n; i++)
      if (w(i) > res) res = w(i);
    return res;
  endfunction
endpackage
module g2 (output logic [g2p::maxw(3)-1:0] o);
  assign o = '0;
endmodule
