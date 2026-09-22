// v11u82 w1 -- LAW B BREAK: the collision lives in an INTERFACE body, which is
// an InstanceBody too, so the law fires there.  Does golden bind the imported
// copy inside an interface as it does inside a module?
package pc;
  wire  [7:0] c_net;
  logic [7:0] c_var;
endpackage

interface ifc (output logic [31:0] o);
  import pc::*;
  wire  [15:0] c_net;
  logic [15:0] c_var;
  for (genvar i = 0; i < 1; i = i + 1) begin : gi
    logic [31:0] c_net; assign c_net = 32'd1;
    logic [31:0] c_var; assign c_var = 32'd2;
  end
  assign o = gi[0].c_net ^ gi[0].c_var;
endinterface

module dut (output logic [31:0] o);
  ifc u_if (.o(o));
endmodule
