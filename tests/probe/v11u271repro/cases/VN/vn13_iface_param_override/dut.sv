// § ndaConstRhsFreshLhs271
package pk;
  localparam int PQ = 6;
  typedef enum logic [3:0] { EA = 1, EB = 9 } e_t;
endpackage
interface ifc #(parameter int IP = 3) ();
  import pk::*;
  wire [31:0] w_ip = IP;
  wire [31:0] w_pq = PQ;
  wire [3:0] w_e = pk::EB;
  wire [3:0] w_b = EA;
endinterface
module dut (output logic [31:0] o);
  ifc #(.IP(11)) u_a ();
  ifc u_b ();
  assign o = u_a.w_ip ^ u_b.w_ip ^ u_a.w_pq ^ u_b.w_e ^ u_a.w_b;
endmodule
