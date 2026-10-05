// § foreachClassPropStringTsShared238
package p;
  class c;
    string m_name;
    function int get_depth();
      int d;
      if (m_name == "") return 0;
      d = 1;
      foreach (m_name[i])
        if (m_name[i] == ".") d++;
      return d;
    endfunction
  endclass
endpackage
module top;
endmodule
