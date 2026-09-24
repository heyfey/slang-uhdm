// verifier probe: the endSelTrack carve-out vs a `$` part-select bound.
// Each cell: a var written WHOLE and also written through a SELECT.
module x3;
  int a1[$]; int a2[$]; int a3[$]; int a4[$]; int a5[$]; int a6[$];
  logic [7:0] v1;
  int v;
  initial begin                 // s1: $ as the LEFT bound
    a1 = '{1, 2, 3};
    a1[$:0] = '{4};
    v = a1[0];
  end
  initial begin                 // s2: $ as the RIGHT bound
    a2 = '{1, 2, 3};
    a2[0:$] = '{4};
    v = a2[0];
  end
  initial begin                 // s3: BIT select write with $ (not a part_select)
    a3 = '{1, 2, 3};
    a3[$] = 4;
    v = a3[0];
  end
  initial begin                 // s4: INTEGER twin (control - must not move)
    a4 = '{1, 2, 3};
    a4[1:0] = '{4};
    v = a4[0];
  end
  initial begin                 // s5: left bound an OPERATION containing $
    a5 = '{1, 2, 3};
    a5[$-1:0] = '{4};
    v = a5[0];
  end
  initial begin                 // s6: packed-vector control, no queue at all
    v1 = 8'h00;
    v1[3:0] = 4'hF;
    v = v1[0];
  end
  initial begin                 // s7: nested block scope
    a6 = '{1, 2, 3};
    begin
      a6[$:0] = '{4};
    end
    v = a6[0];
  end
endmodule
