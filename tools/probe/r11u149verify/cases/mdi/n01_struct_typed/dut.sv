// § multiDeclOneItem140
module dut(input logic [3:0] a, output logic [3:0] y);
  typedef struct packed { logic [1:0] h; logic [1:0] l; } s_t;
  function automatic logic [3:0] f(input logic [3:0] v);
    s_t x, z;
    x = v;
    z = x;
    return z;
  endfunction
  assign y = f(a);
endmodule
