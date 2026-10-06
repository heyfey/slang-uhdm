// § ndaImpEnumConstUnlocated271
package pk;
  typedef enum logic [3:0] { EA = 2, EB = EA + 3, EC } e_t;
endpackage
module sub (output logic [11:0] o);
  import pk::*;
  wire [3:0] w_b = EB;
  wire [3:0] w_c = EC;
  wire [3:0] w_a = EA;
  assign o = {w_a, w_b, w_c};
endmodule
module dut (output logic [11:0] o);
  sub u_s (.o(o));
endmodule
