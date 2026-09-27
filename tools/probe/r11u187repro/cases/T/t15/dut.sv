// § trailIdxCallArgNamesByPath187 (elaborated continuous assignments one and two generate levels down)
module top #(parameter bit P = 1) (input int k, input logic [2:0] i, output logic y, output logic v);
  typedef struct packed { logic [7:0] q; } m_t;
  m_t m;
  function automatic int f(int x); return x; endfunction
  if (P) begin : ga
    logic z, u;
    assign z = m.q[f(k)];
    assign u = m.q[i[1:0]];
    if (P) begin : gb
      logic w;
      assign w = m.q[f(k) + 1];
    end
  end
  assign y = ga.z;
  assign v = ga.gb.w;
endmodule
