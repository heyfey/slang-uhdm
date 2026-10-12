// § castTsInPathIdxByChain296
module dut #(parameter bit E = 1)(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; logic [7:0] k;
  if (E) begin : gi
    assign o = q.f[3'(k)];
  end else begin : ge
    assign o = 1'b0;
  end
endmodule
