// g13 — uvm_is_match's EXACT shape: a package function with a body-level
// STRING local assigned from another call, passed on to a second call in the
// return expression, nothing constant-evaluated.  Golden STAMPS the `s` of
// uvm-1.2's `uvm_is_match` (uvm_globals.svh:400-404), so this arm asks whether
// the shape alone is enough.
package g13p;
  function automatic string g2re(string e); return e; endfunction
  function automatic int rem(string re, string str); return re == str; endfunction
  function automatic bit ismatch(string expr, string str);
    string s;
    s = g2re(expr);
    return (rem(s, str) == 0);
  endfunction
endpackage
module g13 (input logic c, output logic o);
  assign o = c;
endmodule
