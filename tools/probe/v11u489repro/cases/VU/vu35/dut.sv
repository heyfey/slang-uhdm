// § untypedDepUnboundedValue489
class C #(parameter A = 4'd15); localparam B = A + 4'd1; function int get(); return B; endfunction endclass
module top(output int o); C #() c; initial begin c = new; o = c.get(); end endmodule
