// § vsIpsBaseNamesByIps147
module top (input logic [2:0] k, input logic [1:0][7:0] w, output logic [1:0] o);
  function automatic logic [1:0] pick(input logic [1:0][7:0] a, input logic [2:0] b);
    return a[1][b + 1 +: 2];
  endfunction
  assign o = pick(w, k);
endmodule
