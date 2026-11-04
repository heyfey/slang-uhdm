// § modportImplicitHdrNoNetType418
interface bus_if(output o);
    logic [7:0] data;
    modport port(output o, input data);
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
