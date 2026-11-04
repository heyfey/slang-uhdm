// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  function int f(int s);
    int loc;
    loc = s++;
    return loc++;
  endfunction
  task t(int s);
    int loc;
    loc += 1;
    s++;
  endtask
endinterface
