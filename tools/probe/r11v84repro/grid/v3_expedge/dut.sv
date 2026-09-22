// v11u84 v3 — LAW B's EDGES: what an explicit item must NOT clone, and the
// multiplicity when the same name arrives twice.
package eh1;
  wire  [7:0] x_net;
  logic [7:0] x_var = 8'd1;
  parameter int XP = 3;
  localparam int XL = 4;
  typedef logic [3:0] xt_t;
  function automatic int xf(input int a); return a + 1; endfunction
  task automatic xt(); endtask
  typedef enum logic [1:0] {XE0, XE1} xe_t;
  class xc; int q; endclass
  string x_str = "s";
endpackage

package ep_fn;  import eh1::xf;      wire [7:0] o1; endpackage   // a function
package ep_tk;  import eh1::xt;      wire [7:0] o2; endpackage   // a task
package ep_lp;  import eh1::XL;      wire [7:0] o3; endpackage   // a localparam
package ep_ev;  import eh1::XE1;     wire [7:0] o4; endpackage   // an enum VALUE
package ep_cd;  import eh1::xc;      wire [7:0] o5; endpackage   // a class TYPE
package ep_st;  import eh1::x_str;   wire [7:0] o8; endpackage   // a string var
package ep_dup; import eh1::x_net; import eh1::x_net; endpackage // the SAME item twice
package ep_two; import eh1::x_net; import eh1::x_var; endpackage // two items, order

module dut (output logic [31:0] o);
  import eh1::x_net;
  assign o = {24'd0, x_net};
endmodule
