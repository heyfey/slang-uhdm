// § foreachClassPropStringTsShared238
package p;
  class c;
    string m_name;
    extern function int unsigned get_depth();
  endclass
  function int unsigned c::get_depth();
    if (m_name == "") return 0;
    get_depth = 1;
    foreach (m_name[i])
      if (m_name[i] == ".") ++get_depth;
  endfunction
endpackage
module top;
endmodule
