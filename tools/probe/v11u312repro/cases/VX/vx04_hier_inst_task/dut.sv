// § modTfLvTrailIdxNamesByChain312
module leaf; logic [7:0] arr[4]; endmodule
module top; leaf l(); task t(input int i); l.arr[i + 1] = 0; endtask endmodule
