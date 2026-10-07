// § caUserCallRhsNotReduced276
package q; function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction endpackage
module dut (output logic [31:0] o);
  import q::f;
  localparam logic [11:0] K = 12'hFFF;
  assign o = f(K);
endmodule
