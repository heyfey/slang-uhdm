// § foreachArrayNamesTypedef417
typedef logic [3:0] b;
module top;
  logic [3:0] b[2];
  logic [7:0] n;
  always_comb begin
    n = '0;
    foreach (b[i]) n = n + b[i];
  end
endmodule
