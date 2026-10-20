// § modportImplicitHdrNoNetType418
interface input_if(input wire clk);
    logic [7:0] data;
    modport port(input clk, data);
endinterface
module dut(input_if.port in, output logic [7:0] o);
    always @(posedge in.clk) o <= in.data;
endmodule
module top;
    logic clk;
    logic [7:0] o;
    input_if in(clk);
    dut d(in, o);
endmodule
