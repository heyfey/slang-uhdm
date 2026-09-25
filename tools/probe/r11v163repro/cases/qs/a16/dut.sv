// § aggParamFoldQualSpanByView163
package pa;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t XLONG = 16'h1234;
endpackage
package pb;
  localparam pa::s_t YV = pa::XLONG;
endpackage
module dut import pb::*; (output logic [7:0] o);
  assign o = YV.a;
endmodule
module top(output logic [7:0] o); dut d(.o(o)); endmodule
