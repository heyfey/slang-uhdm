// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 6;
  typedef enum logic [3:0] { EA = 1, EB = 9 } e_t;
endpackage
module sub (output logic [31:0] o);
  import pk::PQ;
  import pk::EB;
  wire [31:0] w_p = PQ;
  wire [3:0] w_e = EB;
  assign o = w_p + w_e;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
