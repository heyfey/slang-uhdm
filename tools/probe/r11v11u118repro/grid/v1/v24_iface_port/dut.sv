package cfgp;
  localparam logic [31:0] K = 32'hCAFE_F00D;
  parameter logic [15:0] PK2 = 16'h1234;
  localparam int N = 8;
  localparam logic [3:0][7:0] A2 = 32'h89AB_CDEF;
  localparam logic [1:0][1:0][3:0] A3 = 16'hBEEF;
  localparam logic [7:0] C = {4'hA, 4'h5};
endpackage
interface ifc; logic [7:0] d; modport m(output d); endinterface
module sub (ifc.m p);
  assign p.d = cfgp::K[7:0];
endmodule
module top (output logic [7:0] o);
  ifc i();
  sub u (.p(i));
  assign o = i.d;
endmodule
