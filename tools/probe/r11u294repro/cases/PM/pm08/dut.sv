// § paramInitMemberSelFoldBaseSpan294
// a logic localparam reading bit 0 of a bit [7:0] member
package pk;
  typedef struct packed { bit [7:0] d; logic [3:0] e; } c_t;
  localparam c_t C = '{d: 6, e: 4'h3};
endpackage
module kid #(parameter pk::c_t CFG = pk::C) (output logic o);
  localparam logic B = CFG.d[0];
  assign o = ^{B, 1'b0};
endmodule
module dut(output logic o); kid k0 (.o(o)); endmodule
