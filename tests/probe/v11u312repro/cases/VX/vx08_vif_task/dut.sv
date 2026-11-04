// § modTfLvTrailIdxNamesByChain312
interface ifc; logic [7:0] arr[4]; logic [7:0] v; modport mp(output arr); endinterface
module top; ifc u(); virtual ifc vif; task t(input int i); vif.arr[i + 1] = 0; endtask endmodule
