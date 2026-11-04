// § modTfLvTrailIdxNamesByChain312
interface ifc; logic [7:0] arr[4]; logic [7:0] v; modport mp(output arr); endinterface
module top; ifc u(); int r; task t(input int i); u.arr[i + 1] = r; endtask endmodule
