// § fnRetLitRhsSharesDefConst273
module dut (output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  function automatic st_t f(); return '{a: 4'd1, b: 4'd2}; endfunction
  st_t s;
  assign s = f();
  assign o = s;
endmodule
