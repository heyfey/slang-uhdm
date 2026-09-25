// § multiDeclOneItem140
module dut(input logic [3:0] a, output logic [3:0] y);
  function logic [3:0] f(input logic [3:0] v);
    automatic logic [3:0] t1 = v, t2 = ~v;
    return t1 ^ t2;
  endfunction
  assign y = f(a);
endmodule
