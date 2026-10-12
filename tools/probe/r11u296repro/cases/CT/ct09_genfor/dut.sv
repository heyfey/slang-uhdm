// § castTsInPathIdxByChain296
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef logic [1:0] t2_t;
  st_t q;
  logic [3:0] k;
  logic y1;
  logic [1:0] yy;
  for (genvar g = 0; g < 2; g++) begin : gb
    assign yy[g] = q.f[{1'b1, 2'(k)}];
  end
  assign y1 = yy[0];
endmodule
