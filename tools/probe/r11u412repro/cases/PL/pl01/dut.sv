// § propLocalVarListed412
module top(input logic clk, input logic valid, input logic [7:0] in, input logic [7:0] out);
    property prop;
        int x;
        @(posedge clk) (valid, x = in) |-> ##4 (out == x + 4);
    endproperty
    assert property (prop);
endmodule
