// (r11u191 N0965) the Scr1 shape: the inner call in a for loop over an indexed part select, then later stages
module top(input logic [3:0] sig, output logic o);
  function automatic logic g(input logic [1:0] d);
    return |d;
  endfunction
  function automatic logic f(input logic [3:0] din);
    logic [1:0] s1;
    for (int unsigned i = 0; i < 2; ++i) begin
      s1[i] = g(din[(i+1)*2-1-:2]);
    end
    return g(s1);
  endfunction
  assign o = f(sig);
endmodule
