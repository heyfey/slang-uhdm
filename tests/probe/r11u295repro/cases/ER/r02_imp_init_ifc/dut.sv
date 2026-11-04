// § rawEndLineModel295
package pk;
  int \v.a = 1;
  logic [3:0] \v.b = 4'h2;
endpackage
interface ifc;
  import pk::*;
  logic \own.x ;
endinterface
module dut (output logic o);
  ifc u_i ();
  assign o = 1'b0;
endmodule
