// § seqMatchItemsDropped404
module top();
    int         cycle;
    logic       valid;
    logic       clk;
    logic [7:0] out;
    logic [7:0] in;
    property prop;
        int x;
        @(posedge clk) (valid, x = in) |-> ##4 (out == x + 4);
    endproperty
    assert property (prop) else $error("fail");
endmodule
