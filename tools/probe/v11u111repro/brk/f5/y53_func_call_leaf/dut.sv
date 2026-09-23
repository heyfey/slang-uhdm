package p1;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
  function automatic logic [3:0] f(input int k); return k[3:0]; endfunction
  parameter logic [7:0] X = { f(5), A };
endpackage
module dut (input logic [7:0] i, output logic o);
  import p1::*;
  assign o = (i == X);
endmodule
