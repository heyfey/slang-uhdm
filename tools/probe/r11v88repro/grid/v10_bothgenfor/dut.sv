// v11u88 v10 -- LAW B inside a generate FOR loop in a module and in an
// interface, plus a plain assign in each.
interface ifc ();
  logic [31:0] q;
  for (genvar i = 0; i < 2; i++) begin : gi
    logic [31:0] y;
    assign (pull1, supply0) #2 y = 32'd1;
  end
  assign q = 32'd9;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  for (genvar j = 0; j < 2; j++) begin : gm
    logic [31:0] z;
    assign (weak1, strong0) #3 z = 32'd4;
  end
  assign o = u_if.q ^ gm[0].z;
endmodule
