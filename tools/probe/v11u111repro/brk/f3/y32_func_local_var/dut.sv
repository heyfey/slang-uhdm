package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut (input logic clk, input logic [5:0] i, output logic [5:0] o);
  function automatic logic [5:0] g(input logic [5:0] x);
    q2::row_t t;
    t = x;
    return t;
  endfunction
  always_ff @(posedge clk) o <= g(i);
endmodule
