// r11u83 i6 -- LAW A's array slot in an interface: a fixed-size UNPACKED
// package array (array_var) and an unpacked array of an all-logic struct
// (array_net), the two shapes r11u77 3b/3d and r11u79's builder decided.
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } st_t;
  logic [7:0] v_uarr [0:1];
  st_t        v_sarr [0:1];
  wire  [7:0] n_uarr [0:1];
  logic [7:0] v_flat;
endpackage

interface ifc ();
  import pk::*;
  logic [31:0] i_own;
  if (1) begin : gi
    logic [31:0] v_uarr; assign v_uarr = 32'd1;
    logic [31:0] v_sarr; assign v_sarr = 32'd2;
    logic [31:0] n_uarr; assign n_uarr = 32'd3;
    logic [31:0] v_flat; assign v_flat = 32'd4;
  end
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.i_own;
endmodule
