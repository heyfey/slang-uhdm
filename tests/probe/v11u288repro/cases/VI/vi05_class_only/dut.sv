// § incDecIpsWholeSpan288 — indexed part-select increments in a class method only (prefix, postfix, decrement)
class ic;
  logic [7:0] r; int k;
  function void cm(); r[k +: 2]++; --r[k -: 3]; ++r[k +: 1]; endfunction
endclass
module top; ic c; initial begin c = new(); c.cm(); end endmodule
