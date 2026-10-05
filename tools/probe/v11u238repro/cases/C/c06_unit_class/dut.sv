// § foreachClassPropStringTsShared238
// a $unit class (no package) and a class inside an interface
class uc;
  string m_name;
  extern function int f();
endclass
function int uc::f();
  int n;
  n = 0;
  foreach (m_name[i]) n++;
  return n;
endfunction
interface ifc;
  class ic;
    string m_name;
    function int g();
      int n;
      n = 0;
      foreach (m_name[i]) n++;
      return n;
    endfunction
  endclass
endinterface
module top;
  ifc u();
endmodule
