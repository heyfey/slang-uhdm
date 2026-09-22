// v11u88 v18 -- TWO instances of an interface that both declines a cell and
// lists a net-decl-assign, with the order mixed.
interface ifc ();
  wire [31:0] w_a = 32'd1;
  logic [31:0] c_d;
  assign (weak1, strong0) #2 c_d = 32'd2;
  logic [31:0] c_p;
  assign c_p = 32'd3;
  wire [31:0] w_b = 32'd4;
endinterface

module dut (output logic [31:0] o);
  ifc u1 ();
  ifc u2 ();
  assign o = u1.w_a ^ u1.c_p ^ u2.w_b ^ u2.c_p;
endmodule
