// § vsIpsBaseNamesByIps147
module top (input logic [2:0] k, input logic [1:0][7:0] w, output logic [1:0] o);
  function automatic logic [2:0] f(input logic [2:0] a);
    return a ^ 3'd1;
  endfunction
  always_comb begin : blk
    o = w[1][f(k) +: 2];
  end
endmodule
