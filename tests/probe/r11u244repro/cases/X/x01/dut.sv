// § hpSelIdxPathTrailByChain244
interface ifc;
  typedef struct packed { logic [3:0] k; } ix_t;
  ix_t t;
  logic [7:0] v [16];
  function automatic logic [7:0] rd(); return v[t.k]; endfunction
  always_comb begin v[t.k] = 8'd3; end
endinterface
module top(output logic [7:0] y);
  ifc i();
  assign y = i.rd();
endmodule
