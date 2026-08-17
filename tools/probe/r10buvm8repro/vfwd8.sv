// forward reference inside ONE package: caller declared BEFORE callee
package fp;
  import "DPI-C" context function int dpi_late(string re, string str);
  function bit caller_early (string s, string t);
    return (later_fn(s, t) == 0);
  endfunction
  function int later_fn (string re, string str);
    return dpi_late(re, str);
  endfunction
endpackage
module m_fwd;
  bit z;
  initial z = fp::caller_early("a","b");
endmodule
