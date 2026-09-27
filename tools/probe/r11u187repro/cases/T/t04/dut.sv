// § trailIdxCallArgNamesByPath187
module top #(parameter bit P = 1) (input logic clk, input int k, output logic y);
  typedef struct packed { logic [3:0] q; } m_t;
  m_t m;
  function automatic int f(int x); return x; endfunction
  if (P) begin : ga
    logic z;
    always_comb z = m.q[f(k)];
    if (P) begin : gb
      logic w;
      always_comb w = m.q[f(k)];
    end
  end
  assign y = ga.z;
endmodule
