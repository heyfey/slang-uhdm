// LAW B road F: NON-ANSI leaf
module leaf (a, b);
  input a;
  output [1:0] b;
  wire [1:0] b = {a, a};
endmodule
module orphan ();
  wire a; wire [1:0] b;
  leaf u_l (a, b);
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
