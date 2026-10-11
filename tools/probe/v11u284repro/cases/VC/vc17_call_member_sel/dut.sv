// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  function automatic logic [63:0] f(input logic [63:0] x); return x; endfunction
  logic [31:0] w;
  assign w[31:8] = 0;
  assign o = w;
  if (1) begin : g
    assign w[7:0] = {f(P), P, a};
  end
endmodule
