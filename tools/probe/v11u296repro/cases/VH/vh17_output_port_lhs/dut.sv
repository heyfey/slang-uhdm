// § hcTrailIdxNamesByPortChain296
module src (output logic y);
  assign y = 1'b1;
endmodule
module dut(output logic [31:0] o);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; localparam int I = 4;
  src u (.y(q.f[I+1]));
  assign o = q.f;
endmodule
