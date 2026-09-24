// LAW B road F: leaf with input, output and inout ports
module leaf (input logic a, output logic [3:0] b, inout wire c); assign b = {4{a}}; endmodule
module orphan ();
  logic a; logic [3:0] b; wire c;
  leaf u_l (.a(a), .b(b), .c(c));
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
