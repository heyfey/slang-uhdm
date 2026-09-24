// b9: the function-built package localparam is a PLAIN INT (not a struct),
// read by the module as a parameter default.
package cfg_pkg;
  function automatic int unsigned nb(int unsigned x); return $clog2(x / 8); endfunction
  localparam int unsigned NB = nb(64);
endpackage
module dut #(parameter int unsigned N = cfg_pkg::NB)
  (input logic [3:0] sel_i, output logic [N-1:0] y_o);
  assign y_o = sel_i;
endmodule
