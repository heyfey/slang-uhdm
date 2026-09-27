// § incDecBitSelWholeSpan181 (v11u181 break: inc/dec on an assoc array, a queue, a packed bit, a 2-D element, an index holding a select)
module top;
  int aa[string];
  int q[$];
  logic [7:0] pv;
  int m2 [0:3][0:3];
  int idx [0:3];
  int i, j;
  initial begin
    aa["k"]++;
    q[i]--;
    pv[i]++;
    m2[i][j]++;
    idx[idx[i]]++;
    ++idx[i+j];
  end
endmodule
