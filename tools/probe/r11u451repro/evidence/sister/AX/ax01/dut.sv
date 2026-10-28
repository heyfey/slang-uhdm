// sister-ground face (TypeEmit): the elaborated associative index typespec range
interface bif; logic clk; endinterface
module slave(interface bus);
int memory[logic[31:0]];
initial begin
  for(logic[31:0] i = 32'h0100_0000; i < 32'h0100_0004; i++) begin
    memory[i] = $urandom();
  end
end
endmodule
module top;
  bif BUS();
  slave DUT(.bus(BUS));
endmodule
