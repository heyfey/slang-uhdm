// § caReduceOpKindGate276
module dut #(parameter logic [7:0] P = 8'h3C, parameter logic [7:0] Q = 8'hA5) (input logic [7:0] n, m, output logic [7:0] o);
  function automatic logic [7:0] f(logic [7:0] x); return x; endfunction
  assign o = f(P & n) ^ m;
endmodule
