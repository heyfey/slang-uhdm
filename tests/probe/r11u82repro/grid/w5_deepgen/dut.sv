// v11u82 w5 -- LAW B BREAK: the cell sits TWO hops from the module body, so
// pass 74's one-hop walk must stop at the enclosing generate block and never
// consult the import holder at all.  A row one hop out is the control.
package pc;
  wire  [7:0] h_net;
  logic [7:0] h_var;
endpackage

module dut (output logic [31:0] o);
  import pc::*;
  wire  [15:0] h_net;
  logic [15:0] h_var;
  if (1) begin : G1
    logic [31:0] h_net; assign h_net = 32'd1;   // ONE hop: module body
    if (1) begin : G2
      logic [31:0] h_var; assign h_var = 32'd2; // TWO hops: must stay unbound
    end
  end
  assign o = G1.h_net ^ G1.G2.h_var;
endmodule
