// r11u88 z7 -- LAW B x a COMMA LIST: one statement carrying both a strength
// and a delay declines EVERY cell of the list, not just the first.
interface ifc ();
  logic [31:0] p;
  logic [31:0] q;
  logic [31:0] r;
  assign (weak1, strong0) #2 p = 32'd1, q = 32'd2;
  assign r = 32'd3;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.p ^ u_if.q ^ u_if.r;
endmodule
