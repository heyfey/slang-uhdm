// § aliasWriteModuleScope284v
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut(output logic [3:0] o);
  pk::a_t z = 4'h3;
  assign o = z;
endmodule
