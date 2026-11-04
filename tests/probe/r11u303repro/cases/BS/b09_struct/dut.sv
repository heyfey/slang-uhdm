// § bodyTdBoundSysCallClone303
module dut #(parameter int N = 8) (output logic o);
  typedef struct packed { logic [$clog2(N)-1:0] f; logic g; } s_t;
  s_t a_s;
  assign o = a_s.g;
endmodule
