package q;
  typedef logic [3:0] mask_t;
endpackage
interface bus_if #(parameter q::mask_t M = 4'h2);
  logic [3:0] d;
  assign d = M;
endinterface
module sub #(parameter q::mask_t N = 4'h4) (bus_if b, output logic [3:0] o);
  assign o = b.d ^ N;
endmodule
module dut (output logic [3:0] o);
  bus_if #(.M(4'h6)) bi ();
  sub #(.N(4'h1)) u (.b(bi), .o(o));
endmodule
