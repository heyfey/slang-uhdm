// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  logic [4:0] i;
  function automatic logic [4:0] inc(logic [4:0] v); return v + 1; endfunction
  sub u (.a(q.f[inc(i)]), .y(y));
endmodule
