// § foreachArrayNamesTypedef417
typedef int b;
module top #(parameter int P = 1);
  int n;
  if (P == 1) begin : g
    int b[3];
    initial foreach (b[i]) n += i;
  end
endmodule
