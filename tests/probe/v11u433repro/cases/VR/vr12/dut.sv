// § classRetFillUnsized433
interface ifc;
  class C;
    function logic [3:0] f(); return '1; endfunction
  endclass
endinterface
module top; ifc i(); endmodule
