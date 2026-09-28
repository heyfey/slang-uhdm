// § queueMemberSpanToDim212 — verifier: a queue member in a program-scope struct typedef with a string element and a bound written by a parameter
program pg;
  localparam int B = 3;
  typedef struct { string s[$:B]; int r[$]; } t_t;
  t_t t;
endprogram
module dut(input logic i, output logic o);
  assign o = i;
endmodule
