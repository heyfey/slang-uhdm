// § vsIpsBaseNamesByIps147
module top (input logic [2:0] b, input logic [1:0][7:0] w, output logic [3:0] o);
  task automatic t(output logic [3:0] r);
    r = w[1][b[1:0] * 2 +: 4];
  endtask
  always_comb t(o);
endmodule
