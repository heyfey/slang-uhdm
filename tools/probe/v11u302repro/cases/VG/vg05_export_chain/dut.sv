// § elabImpSelFlatKeepsParent302
// vg05: the selecting package's typedef re-exported through another package that the module imports
package p7;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } w7_t;
  localparam w7_t WSEL = '{a: 32'd4, b: 32'd5};
  typedef logic [WSEL.a-1:0] w1_t;
endpackage
package p8;
  import p7::w1_t;
  import p7::WSEL;
  export p7::w1_t;
  export p7::WSEL;
  localparam int K = WSEL.b;
endpackage
module q import p8::*; (output logic [3:0] o);
  w1_t d;
  assign d = '0;
  assign o = d + K + WSEL.a;
endmodule
module dut(output logic [3:0] o);
  q u_q (.o(o));
endmodule
