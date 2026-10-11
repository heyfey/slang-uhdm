// § aliasWriteModuleScope284v
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
program prg(input logic [3:0] i);
  wire pk::a_t z;
  assign z = i;
endprogram
module dut(input logic [3:0] i, output logic [3:0] o);
  prg p(.i(i));
  assign o = i;
endmodule
