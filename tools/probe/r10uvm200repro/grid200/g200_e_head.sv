// r10uvm200 grid arm E — THE CORPUS HEAD, MINIMISED (the positive control).
// uvm-1.2 base/uvm_globals.svh:410 `parameter UVM_LARGE_STRING =
// UVM_LINE_WIDTH*UVM_NUM_LINES*8-1;` read by :434
// `function string uvm_bits_to_string(logic [UVM_LARGE_STRING:0] str);`,
// wildcard-imported into the design's own package.
package uvmish200e;
  parameter LW200 = 120;
  parameter NL200 = 120;
  parameter BIG200 = LW200*NL200*8-1;
  function string bits_to_string200(logic [BIG200:0] str);
    bits_to_string200 = "x";
  endfunction
  function logic [BIG200:0] string_to_bits200(string s);
    string_to_bits200 = '0;
  endfunction
endpackage

package app200e;
  import uvmish200e::*;
endpackage

module top200e;
  import uvmish200e::*;
  initial $display(BIG200);
endmodule
