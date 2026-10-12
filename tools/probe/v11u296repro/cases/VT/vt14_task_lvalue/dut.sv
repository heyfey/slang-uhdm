// § castTsInPathIdxByChain296
module dut(output logic [31:0] o);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  task automatic t(input logic [7:0] k);
    q.f[3'(k)] = 1'b1;
  endtask
  initial t(8'd2);
  assign o = q.f;
endmodule
