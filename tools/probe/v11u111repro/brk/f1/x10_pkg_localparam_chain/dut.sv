package q;
  typedef logic [3:0] mask_t;
  localparam mask_t Q0 = 4'h1;
  localparam q::mask_t Q1 = Q0 + 4'h2;
endpackage
package r;
  import q::*;
  localparam q::mask_t R0 = Q1;
  localparam mask_t R1 = q::Q1;
endpackage
module dut (output logic [3:0] o, output logic [3:0] p);
  import r::*;
  assign o = R0;
  assign p = R1;
endmodule
