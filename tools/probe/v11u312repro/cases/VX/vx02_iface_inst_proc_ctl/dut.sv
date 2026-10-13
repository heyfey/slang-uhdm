// § modTfLvTrailIdxNamesByChain312
interface ifc; logic [7:0] arr[4]; logic [7:0] v; modport mp(output arr); endinterface
module top; ifc u(); int k; always_comb u.arr[k + 1] = 0; endmodule
