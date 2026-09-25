module top(output logic [1:0] o);
  function automatic logic [1:0] f(input logic [1:0] a);
    logic [3:0][1:0] s;
    s = '0;
    s[0] = 2'd1;
    return s[0] ^ a;
  endfunction
  assign o = f(2'd3);
endmodule
