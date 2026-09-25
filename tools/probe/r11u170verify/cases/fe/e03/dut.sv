// § foreachArrPathVarForm157
interface ifc; logic [3:0] arr [4]; endinterface
module sub (ifc bus, output logic [3:0] o);
  always_comb begin
    o = '0;
    foreach (bus.arr[k]) o ^= bus.arr[k];
  end
endmodule
module top (output logic [3:0] o); ifc b(); sub u(.bus(b), .o(o)); endmodule
