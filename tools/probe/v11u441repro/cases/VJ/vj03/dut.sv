// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  function void f(int s);
    static int st;
    st++;
    garr[s]++;
  endfunction
endinterface
