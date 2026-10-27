// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  function automatic void f(int s);
    int loc;
    s++;
    loc++;
  endfunction
  task automatic t(int s);
    f(s);
    s--;
  endtask
endinterface
module top;
  logic x;
endmodule
