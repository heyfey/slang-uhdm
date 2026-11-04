// § ndaConstRhsFreshLhs271
package pk;
  typedef enum logic [3:0] { EA, ED = 4 } e_t;
endpackage
module sub (output logic [31:0] o);
  import pk::*;
  wire [31:0] w_e = ED;
  assign o = w_e;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
