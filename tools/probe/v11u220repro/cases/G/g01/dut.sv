// § hpVarSelRangeIdxNamesByPath220
typedef struct packed { logic [3:0][7:0] arr; logic v; } st_t;
module top(input st_t s [2], output logic [3:0] o [2][4]);
  always_comb
    for (int i = 0; i < 2; i++)
      for (int j = 0; j < 4; j++)
        o[i][j] = s[i].arr[j][3:0];
endmodule
