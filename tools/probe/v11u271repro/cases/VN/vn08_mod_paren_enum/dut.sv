// § ndaImpEnumConstUnlocated271
package pk;
  typedef enum logic [3:0] { EA = 1, EB = 9 } e_t;
endpackage
module sub (output logic [3:0] o);
  import pk::*;
  wire [3:0] w_p = (EB);
  assign o = w_p;
endmodule
module dut (output logic [3:0] o);
  sub u_s (.o(o));
endmodule
