// § caUserCallRhsNotReduced276
interface ifc;
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  localparam logic [11:0] K = 12'hFFF;
  logic [31:0] o;
  assign o = f(K);
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.o;
endmodule
