// § caUserCallRhsNotReduced276
interface ifc; function automatic logic [31:0] f(logic [11:0] x); return x; endfunction endinterface
module dut (ifc i, output logic [31:0] o);
  localparam logic [11:0] K = 12'hFFF;
  assign o = i.f(K);
endmodule
module top (output logic [31:0] o); ifc u(); dut d(.i(u), .o(o)); endmodule
