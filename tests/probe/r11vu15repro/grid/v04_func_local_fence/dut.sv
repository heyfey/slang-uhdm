module top(input logic [7:0] a, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] x);
    logic [7:0] bs;
    bs      = 8'h00;
    bs[3:0] = 4'hf;
    f       = bs ^ x;
  endfunction
  assign o = f(a);
endmodule
