package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
interface rif;
  q2::row_t r;
  modport m (output r);
endinterface
module dut (input logic [5:0] i, output logic [5:0] o);
  rif ri ();
  assign ri.r = i;
  assign o = ri.r;
endmodule
