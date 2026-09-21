// v11u77 vg -- the DECLARATION-QUALIFIER face.  elabSignal step (1) sets isNet
// FALSE for a CONST and for a non-static declaration; hoistKind77 reads only
// the TYPE.  A const struct, a `var`-spelled struct and an automatic-lifetime
// struct are each asked of golden.
package pq;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } q_t;
  const q_t  q_const = '{default: '0};
  var   q_t  q_var;
        q_t  q_plain;
  wire  q_t  q_wire;
endpackage

module dut (output logic [31:0] o);
  import pq::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] q_const; assign q_const = 32'd1;
    logic [31:0] q_var;   assign q_var   = 32'd2;
    logic [31:0] q_plain; assign q_plain = 32'd3;
    logic [31:0] q_wire;  assign q_wire  = 32'd4;
  end
  assign o = gv[0].q_const ^ gv[0].q_var ^ gv[0].q_plain ^ gv[0].q_wire;
endmodule
