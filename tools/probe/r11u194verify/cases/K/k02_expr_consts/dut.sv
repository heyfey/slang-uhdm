// § classImportParamOwnRefs183: imported parameters whose assignments are expressions of other parameters, read by a class in the importing package
package u;
  parameter int A = 4;
  parameter int B = A * 2;
  localparam int C = B + A - 1;
endpackage
package s;
  import u::*;
  class c;
    bit [C:0] f;
    function int sz(); return B; endfunction
  endclass
endpackage
module top; endmodule
