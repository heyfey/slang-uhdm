// § rawEndLineModel295
package pk;
  int \v.a = 1;
  logic [3:0] \v.b = 4'h2;
endpackage
module dut (output logic [3:0] o);
  import pk::*;
  assign o = \v.b ;
endmodule
