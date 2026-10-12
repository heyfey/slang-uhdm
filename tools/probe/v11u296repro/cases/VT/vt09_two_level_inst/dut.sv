// § castTsInPathIdxByChain296
module leaf(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; logic [7:0] k;
  assign o = q.f[{1'b0, 2'(k)}];
endmodule
module mid(output logic o);
  leaf l(.o(o));
endmodule
module dut(output logic o, output logic p);
  mid m(.o(o));
  leaf l2(.o(p));
endmodule
