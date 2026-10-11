// § aliasWriteModuleScope284v
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  pk::a_t z = 4'h1;
  wire [3:0] w = z;
  assign o = w ^ i;
endmodule
