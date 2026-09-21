// v11u82 w7 -- LAW B BREAK: the k_vn row again (package VAR, module NET ->
// the MODULE's net) in three more shapes -- the module's net is a PORT, the
// module's net is a struct net, and the package's var is a struct var --
// because `impNet || !ownNet` rests on that one row.
package pc;
  logic [7:0] y_pn;                                   // pkg VAR, module PORT net
  typedef struct packed { logic [3:0] a; logic [3:0] b; } ys_t;
  ys_t        y_sv;                                   // pkg struct VAR
  wire  [7:0] y_ns;                                   // pkg NET
endpackage

module dut (output logic [31:0] o, input wire [15:0] y_pn);
  import pc::*;
  wire  [15:0] y_sv;    // module NET vs the package's struct VAR
  pc::ys_t     y_ns;    // module struct VAR vs the package's NET
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] y_pn; assign y_pn = 32'd1;
    logic [31:0] y_sv; assign y_sv = 32'd2;
    logic [31:0] y_ns; assign y_ns = 32'd3;
  end
  assign o = gv[0].y_pn ^ gv[0].y_sv ^ gv[0].y_ns;
endmodule
