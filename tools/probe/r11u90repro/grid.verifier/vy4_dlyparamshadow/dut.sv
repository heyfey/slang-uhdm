// v11u90 vy4 -- a NET named D in an inner generate scope beside the module
// parameter D that the delay names.
module sub (output logic [31:0] o);
  parameter int D = 4;
  logic [31:0] c;
  assign #D c = 32'd10;
  if (1) begin : g
    wire [31:0] D = 32'd7;
  end
  assign o = c ^ g.D;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
