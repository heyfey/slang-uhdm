// r11u85 x6 -- LAW C with NO parameter override, so the elaborated
// `param_assign` is golden's own and the fold is the arm's HEAD: the cast
// element sits in the interface's DEFAULT pattern.
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
  localparam int K = 1;
endpackage

interface ifc #(parameter pk::s_t C = '{n: 8'(pk::K + 1), m: 8'd5}) ();
  logic [31:0] y;
  assign y = C.n;
endinterface

module dut (output logic [31:0] o);
  ifc u_d ();
  assign o = u_d.y;
endmodule
