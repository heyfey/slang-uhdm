// § insideSetParamFoldKeepsPa270
package up;
  parameter int A = 1;
  parameter int B = 2;
  class item;
    rand int k;
    constraint c1 { k inside {A, B}; }
    function bit chk(); return k inside {A, B}; endfunction
  endclass
endpackage
module top;
  import up::*;
  item i;
endmodule
