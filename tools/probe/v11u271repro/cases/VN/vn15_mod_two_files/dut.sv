// § ndaImpEnumConstUnlocated271
`include "pk.svh"
module sub (output logic [3:0] o);
  import pk::*;
  wire [3:0] w_e = EB;
  wire [3:0] w_q = pk::EA;
  assign o = w_e ^ w_q;
endmodule
module dut (output logic [3:0] o);
  sub u_s (.o(o));
endmodule
