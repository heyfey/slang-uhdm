typedef struct packed { logic [3:0] v; logic [1:0][1:0] pg; logic ok; } e_t;
module dut(input logic [21:0] din, input logic k, output logic [1:0] o);
  function automatic logic [1:0] f(e_t [1:0] t, logic i);
    return t[i].pg[1][1:0];
  endfunction
  assign o = f(din, k);
endmodule
