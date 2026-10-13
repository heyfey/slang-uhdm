// § modTfLvTrailIdxNamesByChain312
interface ifc; logic [7:0] arr[4]; logic [7:0] v; modport mp(output arr); task t(input int i); arr[i + 1] = 0; v[i +: 2] = 0; endtask endinterface
module top; ifc u(); endmodule
