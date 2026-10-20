// § modportImplicitHdrNoNetType418
interface bus_if(input tri clk);
    logic [7:0] data;
    modport port(input clk, input data);
endinterface
module dut(bus_if.port b, output logic [7:0] o);
    assign o = b.data;
endmodule
module top;
    wire [7:0] w;
    logic [7:0] o;
    bus_if bi(w[0]);
    dut d(bi, o);
endmodule
