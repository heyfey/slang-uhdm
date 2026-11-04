// § rawEndLineModel295
package pk;
  int va = 1;
  logic [7:0] varr [0:1];
endpackage
module dut (output logic [7:0] o);
  import pk::*;
  assign o = varr[0];
endmodule
