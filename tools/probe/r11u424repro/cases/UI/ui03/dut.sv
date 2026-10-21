// § ifcUnitVarRefMintsNet424
int cnt = 3;
interface ifc;
  function int get();
    return cnt;
  endfunction
endinterface
module top;
  ifc u ();
  initial $display("%0d", u.get());
endmodule
