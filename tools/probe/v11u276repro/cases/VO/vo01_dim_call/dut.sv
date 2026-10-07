// § elabRhsOwnTsNotDefFormal276
module dut (input logic [31:0] n, output logic [31:0] o);
  function automatic int f(logic [11:0] x); return x[3:0]; endfunction
  localparam logic [11:0] K = 12'h007;
  logic [f(K):0] w;
  assign w = n[7:0];
  assign o = {24'b0, w};
endmodule
