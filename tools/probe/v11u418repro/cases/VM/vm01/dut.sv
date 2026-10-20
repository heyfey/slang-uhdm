// § modportImplicitHdrNoNetType418
interface bus_if(inout [7:0] d);
    logic [7:0] data;
    modport port(inout d, input data);
endinterface
module dut(bus_if.port b, output logic [7:0] o);
    assign o = b.data;
endmodule
module top;
    wire [7:0] w;
    logic [7:0] o;
    bus_if bi(w);
    dut d(bi, o);
endmodule
