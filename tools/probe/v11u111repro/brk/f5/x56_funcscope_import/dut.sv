package p1;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
  parameter logic [7:0] X = { 4'h1, A };
endpackage
module dut (input logic [7:0] i, output logic o);
  function automatic logic f(input logic [7:0] a);
    import p1::*;
    return a == X;
  endfunction
  assign o = f(i);
endmodule
