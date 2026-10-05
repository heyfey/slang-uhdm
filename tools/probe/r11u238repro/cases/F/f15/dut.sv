// § foreachClassPropStringTsShared238
module top;
  class c;
    string m_name;
    extern function int depth();
  endclass
  function int c::depth();
    foreach (m_name[i]) depth++;
  endfunction
  c o;
  int r;
  initial begin o = new; r = o.depth(); end
endmodule
