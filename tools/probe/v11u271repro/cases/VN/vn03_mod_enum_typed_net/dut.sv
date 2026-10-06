// § ndaImpEnumConstUnlocated271
package pk;
  typedef enum logic [3:0] { EA = 1, EB = 9 } e_t;
endpackage
module sub (output logic [3:0] o);
  import pk::*;
  wire e_t w_e = EB;
  wire pk::e_t w_q = pk::EA;
  assign o = w_e ^ w_q;
endmodule
module dut (output logic [3:0] o);
  sub u_s (.o(o));
endmodule
