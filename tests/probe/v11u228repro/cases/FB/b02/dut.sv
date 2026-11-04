// § sizeBitNetIsVar228 — a typedef'd bit packed port in a child instantiated twice with two widths
module sub #(parameter int N = 2) (input bit [N-1:0][2:0] pp, output logic [7:0] o);
  typedef bit [N-1:0][2:0] t_t;
  wire [7:0] w = $size(pp);
  assign o = w;
endmodule
module dut (output logic [7:0] o1, o2);
  sub #(.N(3)) u1 (.pp('0), .o(o1));
  sub #(.N(5)) u2 (.pp('0), .o(o2));
endmodule
