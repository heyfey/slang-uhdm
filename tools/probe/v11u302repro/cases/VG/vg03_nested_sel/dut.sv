// § elabImpSelFlatKeepsParent302
// vg03: a nested pattern selected two levels deep in the package, imported into a module inside a generate block
package p7;
  typedef struct packed { logic [15:0] x; logic [15:0] y; } in_t;
  typedef struct packed { in_t s; logic [31:0] b; } w7_t;
  localparam w7_t WSEL = '{s: '{x: 16'd4, y: 16'd5}, b: 32'd6};
  typedef logic [WSEL.s.x-1:0] w1_t;
endpackage
module q import p7::*; (output logic [3:0] o);
  w1_t d;
  assign d = '0;
  assign o = d;
endmodule
module dut(output logic [3:0] o);
  if (1) begin : g
    q u_q (.o(o));
  end
endmodule
