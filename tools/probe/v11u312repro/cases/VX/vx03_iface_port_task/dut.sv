// § modTfLvTrailIdxNamesByChain312
interface ifc; logic [7:0] arr[4]; logic [7:0] v; modport mp(output arr); endinterface
module sub(ifc p); task t(input int i); p.arr[i + 1] = 0; endtask endmodule
module top; ifc u(); sub s(u); endmodule
