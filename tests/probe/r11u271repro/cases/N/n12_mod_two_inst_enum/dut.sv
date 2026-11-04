// § ndaConstRhsFreshLhs271
package pk;
  typedef enum logic [1:0] { EA, EB = 2 } e_t;
endpackage
module sub (output logic [31:0] o);
  wire [31:0] w_e = pk::EB;
  assign o = w_e;
endmodule
module dut (output logic [31:0] o1, output logic [31:0] o2);
  sub u_a (.o(o1));
  sub u_b (.o(o2));
endmodule
