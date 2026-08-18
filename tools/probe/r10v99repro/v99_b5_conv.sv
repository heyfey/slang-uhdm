// v99 b5 - implicit-conversion probe: does a compound first bound wrapped in a
// slang implicit Conversion escape the R1 gate?  Plus sequences, foreach, wait,
// randcase and a covergroup with-clause.
module mub5 (input logic ckb5);
  logic [63:0] wq5;
  byte         bb5;
  shortint     sh5;
  logic [3:0]  n45;
  int          i5, j5, k5, m5, o5, p5;
  int          aq5 [$];
  int          ar5 [4];

  always @(*) begin
    // wide LHS, narrow compound first bound -> conversion candidate
    if (wq5 inside {[bb5+1:bb5+4]})       i5 = 1;
    // narrow LHS, int compound first bound
    if (n45 inside {[sh5+1:9]})           j5 = 2;
    // wide LHS, narrow PRIMARY first bound (must truncate)
    if (wq5 inside {[bb5:9]})             k5 = 3;
    // narrow LHS, wide primary first bound
    if (n45 inside {[wq5:64'd9]})         m5 = 4;
    // signed/unsigned mix, primary
    if (sh5 inside {[bb5:sh5]})           o5 = 5;
    // foreach body
    foreach (ar5[ix5]) if (ar5[ix5] inside {[2:6], 8}) p5 = 6;
  end

  // wait statement
  initial begin
    wait (i5 inside {[1:4]});
    randcase
      1 : if (j5 inside {[5:7]}) k5 = 7;
      2 : k5 = 8;
    endcase
  end

  // sequence + property
  sequence sqb5;
    @(posedge ckb5) i5 inside {[1:3], 5};
  endsequence
  assert property (sqb5);

  // covergroup with a with-clause on a ranged inside
  covergroup cgb5 @(posedge ckb5);
    cpb5 : coverpoint i5 {
      bins wb5[] = {[0:7]} with (item inside {[2:5]});
    }
  endgroup
endmodule
