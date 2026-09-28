// § tpArrBoundAtLeftOperand196: arb_idx_cast's shape, a type-parameter-typed packed array whose bound folds from 2**N-2
module dut #(parameter int unsigned NumLevels = 2, parameter int unsigned W = 2,
             parameter type idx_t = logic [W-1:0]) (input logic a, output idx_t o);
  idx_t [2**NumLevels-2:0] index_nodes;
  assign o = index_nodes[0];
endmodule
