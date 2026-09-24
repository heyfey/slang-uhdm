// r11u85 a6 -- one `assign` statement, TWO cells, ONE delay and ONE strength
// pair: does each elab clone carry the shared drive fields?
interface ifc ();
  logic [31:0] p;
  logic [31:0] q;
  logic [31:0] r;
  logic [31:0] t;
  assign #4 p = 32'd1, q = 32'd2;
  assign (weak1, strong0) r = 32'd3, t = 32'd4;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.p ^ u_if.q ^ u_if.r ^ u_if.t;
endmodule
