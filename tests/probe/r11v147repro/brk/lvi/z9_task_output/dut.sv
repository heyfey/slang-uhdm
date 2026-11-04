// § lvIdxBitSelAtIndex147
module top (input logic [2:0] b, output logic [3:0] w);
  task automatic setb(output logic q);
    q = 1'b1;
  endtask
  always_comb begin
    w = '0;
    setb(w[b[1]]);
  end
endmodule
