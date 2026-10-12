// § elabImpSelFlatKeepsParent302
// f03: CONTROL - selected only from the module (the package never reduces it)
package p;
  typedef struct packed { logic [39:0] a; logic [39:0] b; } w_t;
  localparam w_t WM = '{a: 40'd4, b: 40'd5};
endpackage
module q import p::*; (output logic [39:0] o);
  assign o = WM.a;
endmodule
module dut(output logic [39:0] o);
  q u_q (.o(o));
endmodule
