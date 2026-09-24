// OUT-OF-BODY class method in a package: pkgScopeInst is NON-NULL for an oob
// definition (TaskFuncEmit tsInst = oobHomePkg), so the class-method fence of
// § pkgRetTopCallArgFormalTs8 may LEAK.
package op;
  import "DPI-C" context function int dpi_o(string re, string str);
  function int freefn(string re, string str);
    return dpi_o(re, str);
  endfunction
  class C;
    extern function bit oobm (string s, string t);
    function bit inlm (string s, string t);
      return (dpi_o(s, t) == 0);
    endfunction
  endclass
  function bit C::oobm (string s, string t);
    return (dpi_o(s, t) == 0);
  endfunction
endpackage
module m_oob;
  bit z;
  op::C c;
  initial begin c = new(); z = c.oobm("a","b"); end
endmodule
