// § aliasWriteModuleScope284v
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
interface ifc(input logic [3:0] i);
  wire pk::a_t z;
  assign z = i;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u(.i(i));
  assign o = u.z;
endmodule
