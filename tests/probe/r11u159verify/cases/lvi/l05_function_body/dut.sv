// § lvIdxBitSelAtIndex147
module top (input logic [2:0] b, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [2:0] idx);
    logic [7:0] w;
    w = '0;
    w[idx[2]] = 1'b1;
    return w;
  endfunction
  assign o = f(b);
endmodule
