// r11v75 xe — LAW B's BINDING HALF BY THE HOME'S KIND.  The helper returns
// whatever `pkg->find(name)` answers and the caller binds whatever `netMap`
// holds for it; only an `array_net` is fenced.  If golden declines an
// UNPACKED-ARRAY or STRUCT home the way it declines the gen-scope array net,
// this binds objects golden does not have.
package pv;
  logic [15:0]      s_ns;        // a plain package variable (the measured face)
  logic [7:0]       a_ns [0:1];  // an UNPACKED-ARRAY package variable
  typedef struct packed { logic [7:0] x; logic [7:0] y; } st_t;
  st_t              t_ns;        // a STRUCT package variable
  logic [1:0][7:0]  pkd_ns;      // a PACKED-array package variable
endpackage

module dut (output logic [31:0] o);
  import pv::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gk
    logic [31:0] s_ns;   assign s_ns   = 32'd1;
    logic [31:0] a_ns;   assign a_ns   = 32'd2;
    logic [31:0] t_ns;   assign t_ns   = 32'd3;
    logic [31:0] pkd_ns; assign pkd_ns = 32'd4;
  end
  assign o = gk[0].s_ns ^ gk[0].a_ns ^ gk[0].t_ns ^ gk[0].pkd_ns;
endmodule
