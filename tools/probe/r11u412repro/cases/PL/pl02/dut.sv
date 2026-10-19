// § propLocalVarListed412
module top(input logic clk, input logic valid, input logic [7:0] in, input logic [7:0] out);
    property p2;
        byte a; int b;
        @(posedge clk) (valid, a = in, b = 1) |-> ##1 (out == a + b);
    endproperty
    property p3;
        integer c;
        @(posedge clk) (valid, c = in) |-> (out == c);
    endproperty
    assert property (p2);
    assert property (p3);
endmodule
